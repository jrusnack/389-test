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

require "test_framework/testsuite"
require "rexml/document"
require "rexml/element"
require "test_framework/scheduler"
require "test_framework/report_builder"

class Controller
    def initialize(configuration)
        @configuration = configuration
        @testsuites = Array.new

        # create output directory if it doesnt exist already
        FileUtils.mkdir_p(@configuration.output_directory)
        FileUtils.rm_r Dir.glob(@configuration.output_directory + "/*")

        # fill the testsuites array with all testsuites that can be found
        @testsuites_paths = TestsuiteExplorer.get_testsuites_paths(@configuration)
        @testsuites_paths.each do |testsuite_path|
            @testsuites << create_testsuite(testsuite_path)
        end
        # filter only those that should be run according to the @configurations.testsuites_to_run
        filter_testsuites(@testsuites)
        # issue warning if testsuite specified in @configurations.testsuites_to_run is not 
        # present in @testsuites array (probably mistyped name)
        if @configuration.testsuites_to_run
            @configuration.testsuites_to_run.each do |ts_to_run_name|
                ts_to_run_found = false
                @testsuites.each do |ts|
                    ts_to_run_found = true if ts.name == ts_to_run_name
                end
                puts "Warning: testsuite #{ts_to_run_name} not found." if ts_to_run_found != true
            end
        end
    end

    def execute
        @configuration.repositories.each do |repo|
            Yum.add_repo(repo)
        end
        if @configuration.upgrade then
            execute_upgrade
        else
            execute_normal
        end
        @configuration.repositories.each do |repo|
            Yum.remove_repo(repo)
        end
    end

    def execute_upgrade
        total_timer = Timer.new.start

        # Check whether both packages are available from yum
        [@configuration.upgrade_from, @configuration.upgrade_to].each do |package|
            if ! Yum.package_available?(package)
                puts "Aborting - package #{package} not available."
                exit
            end
        end

        # load special Environment testsuite
        require 'test_framework/environment'
        output_file = @configuration.output_directory + "/#{Testsuite::Builder.name}"
        @environment = Testsuite::Builder.get_testsuite(Log.new(output_file), @configuration)

        # Install version of DS to upgrade from (in Envorinment testsuite)
        @environment.execute_before_upgrade
        if @environment.failed_count > 0
            puts "Aborting - before upgrade of Environment failed"
            exit
        end

        # Run before_upgrade of each testsuite - they usually set up their DS instances
        @testsuites.each do |testsuite|
            testsuite.execute_before_upgrade
        end

        # Upgrade installation of DS (in Envorinment testsuite)
        @environment.execute_after_upgrade
        @environment.execute_testcases
        if @environment.failed_count > 0
            puts "Aborting - testcase in Environment failed."
            exit
        end

        # Run after_upgrade of each testsuite
        @testsuites.each do |testsuite|
            testsuite.execute_after_upgrade
        end

        case @configuration.execution
        when :parallel
            run_testsuites_concurrently
        when :sequential
            run_testsuites_sequentially
        else
            raise RuntimeError.new("Unknown configuration.execution: #{@configuration.execution}")
        end

        @environment.execute_cleanup
        @duration = total_timer.get_time
    end

    def execute_normal
        total_timer = Timer.new.start

        # load special Environment testsuite
        require 'test_framework/environment'
        output_file = @configuration.output_directory + "/#{Testsuite::Builder.name}"
        @environment = Testsuite::Builder.get_testsuite(Log.new(output_file), @configuration)

        # Execute startup and testcases of Environment before running any other testsuites
        @environment.execute_startup
        @environment.execute_testcases

        # Only if startup and all testcases of Environment passed, execute testsuites
        if @environment.failed_count == 0 then
            case @configuration.execution
            when :parallel
                run_testsuites_concurrently
            when :sequential
                run_testsuites_sequentially
            else
                raise RuntimeError.new("Unknown configuration.execution: #{@configuration.execution}")
            end
        end

        @environment.execute_cleanup
        @duration = total_timer.get_time
    end

    def write_reports
        report_builder = ReportBuilder.new(@environment, @testsuites, @duration)
        if @configuration.write_xml_report then
            output_file = @configuration.output_directory + "/" + @configuration.xml_report_file
            File.open(output_file, 'w') {|file| report_builder.get_xml_report.write(file, 4)}
        end
        if @configuration.write_junit_report then
            output_file = @configuration.output_directory + "/" + @configuration.junit_report_file
            File.open(output_file, 'w') {|file| report_builder.get_junit_report.write(file, 4)}
        end
        puts report_builder.plaintext_summary_report
    end 

    private

    def create_testsuite(testsuite_path)
        require testsuite_path
        relative_path = testsuite_path.gsub(@configuration.test_directory,'')
        output_file = @configuration.output_directory + relative_path.gsub('.rb','')
        testsuite = Testsuite::Builder.get_testsuite(Log.new(output_file), @configuration)
        return testsuite
    end

    def filter_testsuites(arr_of_testsuites)
        return if @configuration.testsuites_to_run == nil
        arr_of_testsuites.delete_if do |ts|
            (! @configuration.testsuites_to_run.include?(ts.name)) && ts.name != "environment"
        end
    end

    def run_testsuites_sequentially
        @testsuites.each do |ts|
            ts.execute
        end
    end

    def run_testsuites_concurrently
        scheduler = Scheduler.new(@testsuites)
        scheduler.run
    end
end