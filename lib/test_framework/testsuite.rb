
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
    attr_reader :name, :passed_count, :failed_count, :skipped_count, :options, :duration

    class Builder
        @@name = nil
        @@options = nil

        def self.name=(name)
            @@name = name
        end

        def self.options=(options)
            @@options = options
        end

        def self.testcases(&block)
            @@block = block
        end

        def self.name
            @@name
        end

        def self.get_testsuite(log, configuration)
            testsuite = Testsuite.new(@@name, log, @@options, configuration)
            # Probably the ugliest thing ..
            testsuite.instance_eval(&@@block)
            return testsuite
        end
    end

    def initialize(name, log, options, configuration)
        @name = name
        @log = log
        @options = options
        @configuration = configuration
        @testcases = Array.new
        @startup = nil
        @cleanup = nil
        @passed_count = 0
        @failed_count = 0
        @skipped_count = 0
        @duration = nil
    end

    def execute
        timer = Timer.new.start
        execute_startup
        execute_testcases
        execute_cleanup
        @duration = timer.get_time
    end

    def execute_startup
        log(testsuite_header)
        run_testcase(@startup) if @startup != nil
    end

    def execute_testcases
        # skip all if startup failed
        if @startup.result == Testcase::FAIL
            @skipped_count += 1
            return
        end

        @testcases.each do |testcase|
            run_testcase(testcase)
        end
    end

    def execute_cleanup
        run_testcase(@cleanup) if @cleanup != nil
        log(testsuite_footer)
    end

    def run_testcase(testcase)
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
            testcase.result = Testcase::FAIL
            testcase.error = error
            @failed_count += 1
            log_error(error)
            log(testcase.footer)
            return false
        ensure
            testcase.duration = timer.get_time
        end
    end

    def to_xml
        testsuite_xml = REXML::Element.new("testsuite")
        testsuite_xml.add(REXML::Element.new("name").add_text(@name))
        if @startup
            testsuite_xml.add(@startup.to_xml)
        end
        @testcases.each do |testcase|
            testsuite_xml.add(testcase.to_xml)
        end
        if @cleanup
            testsuite_xml.add(@cleanup.to_xml)
        end
        return testsuite_xml
    end

    def to_junit_xml
        number_of_tests = @testcases.size
        number_of_tests += startup ? 1 : 0
        number_of_tests += cleanup ? 1 : 0
        testsuite_xml = REXML::Element.new("testsuite")
        testsuite_xml.add_attribute('name', @name)
        testsuite_xml.add_attribute('time', @duration)
        testsuite_xml.add_attribute('tests', number_of_tests)
        testsuite_xml.add_attribute('passed', @passed_count)
        testsuite_xml.add_attribute('failed', @failed_count)
        testsuite_xml.add_attribute('skipped', @skipped_count)
        if @startup
            testsuite_xml.add(@startup.to_junit_xml)
        end
        @testcases.each do |testcase|
            testsuite_xml.add(testcase.to_junit_xml)
        end
        if @cleanup
            testsuite_xml.add(@cleanup.to_junit_xml)
        end
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

    private

    def testsuite_header
        "#"*20 + " Testsuite #{@name} " + "#"*20
    end

    def testsuite_footer
        "\n" + "#"*20 + " End of #{@name} " + "#"*20
    end

    #########################################
    # Functions for setting up the testcase #

    def startup(&block)
        @startup = Testcase.new("startup", @name, nil, nil, &block)
        @startup.result = Testcase::PASS    # Passes by default
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

    def run(&block)
        @testcases.concat(Testcase::Builder.create_testcases(&block))
    end

    def cleanup(&block)
        @cleanup = Testcase.new("cleanup", @name, nil, nil, &block)
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