# 389-test - testing framework for 389 Directory Server
#
# Copyright (C) 2013 Jan Rusnacko
#
# This file is part of 389-test.
#
# 389-test is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# 389-test is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with 389-test. If not, see <http://www.gnu.org/licenses/>.
#
# For alternative license options, contact the copyright holder.
#
# Jan Rusnacko <rusnackoj@gmail.com>

require "test_framework/testcase"
require "test_framework/failure"
require "rexml/element"
require 'util/log'
require 'util/os'
require 'util/timer'
require 'ldap/ldap'

class Testsuite
    include LogMixin
    include OS
    include Ldap
    attr_accessor :duration
    attr_reader :name, :passed_count, :failed_count, :skipped_count

    TESTCASE="Testcase"
    TESTSUITE="Testsuite"

    class Builder

        def self.new(name, type, block)
            @@name = name
            @@block = block
            @@type = type
        end

        def self.name
            return @@name
        end

        def self.get_testsuite(log, configuration)
            testsuite = Testsuite.new(@@name, log, @@type, configuration)
            # Probably the ugliest thing ..
            testsuite.instance_eval(&@@block) if @@block
            return testsuite
        end
    end

    def initialize(name, log, type, configuration)
        @name = name
        @log = log
        @type = type
        @options = nil
        @purpose = nil
        @dependencies = nil
        @configuration = configuration
        @testcases = Array.new
        @startup = nil
        @cleanup = nil
        @passed_count = 0
        @failed_count = 0
        @skipped_count = 0
    end

    def execute
        if @configuration.upgrade then
            return if @before_upgrade == nil || @after_upgrade == nil
            # before_upgrade and after_upgrade already executed, instead of startup
            execute_testcases
            execute_cleanup
        else
            execute_startup
            execute_testcases
            execute_cleanup
        end
    end

    def execute_startup
        @log.create_logdir
        log(testsuite_header)
        if @startup != nil
            timer = Timer.new.start
            run_testcase(@startup)
            @startup.duration = timer.get_time
        end
    end

    def execute_before_upgrade
        @log.create_logdir
        log(testsuite_header)
        if @before_upgrade != nil
            timer = Timer.new.start
            run_testcase(@before_upgrade)
            @before_upgrade.duration = timer.get_time
        end
    end

    def execute_after_upgrade
        if @after_upgrade != nil
            timer = Timer.new.start
            run_testcase(@after_upgrade)
            @after_upgrade.duration = timer.get_time
        end
    end

    def execute_testcases
        # skip all if startup failed
        #if @startup && @startup.result == Testcase::FAIL
        if @startup.result == Testcase::FAIL
            @skipped_count += @testcases.size
            return
        end

        @testcases.each do |testcase|
            run_testcase(testcase)
        end
    end

    def execute_cleanup
        if @cleanup != nil
            timer = Timer.new.start
            run_testcase(@cleanup)
            @cleanup.duration = timer.get_time
        end
        log(testsuite_footer)
    end

    def run_testcase(testcase)
        if testcase.met_dependencies? == false then
            @skipped_count += 1
            return
        end
        timer = Timer.new.start
        begin
            @log.testcase = testcase
            log(testcase.header)
            testcase.execute
            # if no exception was raised, testcase passed
            testcase.result = Testcase::PASS
            @passed_count += 1
            log(testcase.footer)
            @log.testcase = nil
            return true
        rescue RuntimeError, Failure => error
            log_error(error)
            if @configuration.debug_mode
                log("[DEBUG] Aborting execution - detected failure.")
                puts "Aborted"
                exit
            end
            testcase.result = Testcase::FAIL
            testcase.error = error
            @failed_count += 1
            log(testcase.footer)
            return false
        ensure
            testcase.duration = timer.get_time
        end
    end

    def to_xml
        testsuite_xml = REXML::Element.new("testsuite")
        testsuite_xml.add(REXML::Element.new("name").add_text(@name))
        # If testcase has a duration set, it was executed and should be included
        testsuite_xml.add(@startup.to_xml) if @startup && @startup.duration
        testsuite_xml.add(@before_upgrade.to_xml) if @before_upgrade && @before_upgrade.duration
        testsuite_xml.add(@after_upgrade.to_xml) if @after_upgrade && @after_upgrade.duration
        @testcases.each do |testcase|
            testsuite_xml.add(testcase.to_xml)
        end
        testsuite_xml.add(@cleanup.to_xml) if @cleanup && @cleanup.duration
        return testsuite_xml
    end

    def to_junit_xml
        number_of_tests = @testcases.size
        number_of_tests += 1 if @startup
        number_of_tests += 1 if @cleanup
        testsuite_xml = REXML::Element.new("testsuite")
        testsuite_xml.add_attribute('name', @name)
        testsuite_xml.add_attribute('time', duration)
        testsuite_xml.add_attribute('tests', number_of_tests)
        testsuite_xml.add_attribute('passed', @passed_count)
        testsuite_xml.add_attribute('failed', @failed_count)
        testsuite_xml.add_attribute('skipped', @skipped_count)
        testsuite_xml.add(@startup.to_junit_xml) if @startup && @startup.duration
        testsuite_xml.add(@before_upgrade.to_junit_xml) if @before_upgrade && @before_upgrade.duration
        testsuite_xml.add(@after_upgrade.to_junit_xml) if @after_upgrade && @after_upgrade.duration
        @testcases.each do |testcase|
            testsuite_xml.add(testcase.to_junit_xml)
        end
        testsuite_xml.add(@cleanup.to_junit_xml) if @cleanup && @cleanup.duration
        return testsuite_xml
    end

    def store_results
        # Create Hash {:testcase_name => serialized_results}
        testcases_serialized = Hash.new
        testcases_serialized[@startup.name] = @startup.store_results
        @testcases.each do |testcase|
            testcases_serialized[testcase.unique_name] = testcase.store_results
        end
        testcases_serialized[@cleanup.name] = @cleanup.store_results
        return Marshal.dump([testcases_serialized, @passed_count, @failed_count, @skipped_count, @duration])
    end

    def load_results(string)
        # Reload values of passed, failed and skipped
        testcases_serialized, @passed_count, @failed_count, @skipped_count, @duration = Marshal.load(string)
        # Reload results of all testcases
        @startup.load_results(testcases_serialized[@startup.name])
        @testcases.each do |testcase|
            testcase.load_results(testcases_serialized[testcase.unique_name])
        end
        @cleanup.load_results(testcases_serialized[@cleanup.name])
    end

    def testcase_count
        count = @testcases.size
        if @configuration.upgrade then
            count += 1 if @before_upgrade
            count += 1 if @after_upgrade
        else
            count += 1 if @startup
        end
        count += 1 if @cleanup
        return count
    end

    def passed_percent
        return @passed_count*100/Float(testcase_count)
    end

    def failed_percent
        return @failed_count*100/Float(testcase_count)
    end

    def skipped_percent
        return @skipped_count*100/Float(testcase_count)
    end

    def get_options
        return @options
    end

    private

    def testsuite_header
        "#"*20 + " #{@type} #{@name} " + "#"*20
    end

    def testsuite_footer
        "\n" + "#"*20 + " End of #{@name} " + "#"*20
    end

    def duration
        duration = 0
        [@startup, @before_upgrade, @after_upgrade, @cleanup].concat(@testcases).each do |tc|
            duration += tc.duration if tc && tc.duration
        end
        return duration
    end

    #########################################
    # Functions for setting up the testcase #

    def startup(&block)
        @startup = Testcase.new("startup", @name, nil, nil, nil, &block)
        @startup.result = Testcase::PASS    # Passes by default
    end

    def before_upgrade(&block)
        @before_upgrade = Testcase.new("before upgrade", @name, nil, nil, nil, &block)
    end

    def after_upgrade(&block)
        @after_upgrade = Testcase.new("after upgrade", @name, nil, nil, nil, &block)
    end

    def testcase(testcase_name)
        if testcase_name == "startup" || testcase_name == "cleanup"
            raise ArgumentError.new("Invalid testcase name #{name}")
        end
        Testcase::Builder.new(testcase_name, @name)
    end

    def with(*parameters)
        Testcase::Builder.add_parameters(parameters)
    end

    def purpose(purpose)
        Testcase::Builder.add_purpose(purpose)
    end

    def depends_on(*dependencies)
        if Testcase::Builder.name == nil
            @dependencies = dependencies
        else
            Testcase::Builder.add_dependencies(dependencies)
        end
    end

    def run(&block)
        @testcases.concat(Testcase::Builder.create_testcases(&block))
    end

    def check(testcase_name)
        Testcase::Builder.new(testcase_name, @name)
    end

    def options(options)
        @options = options
    end

    def cleanup(&block)
        @cleanup = Testcase.new("cleanup", @name, nil, nil, nil, &block)
        @cleanup.result = Testcase::PASS    # Passes by default
    end

    ###########################
    # Functions used in tests #

    def assert(message, condition)
        if condition
            @log.info(message, 'PASS')
        else
            raise Failure.new(message)
        end
    end

    def assert_equal(message, expected, actual)
        if expected == actual
            @log.info(message, 'PASS')
        else
            raise Failure.new(message + " Expected: #{expected}, but was #{actual}.")
        end
    end
end