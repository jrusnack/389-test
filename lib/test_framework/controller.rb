
require "test_framework/testsuite"
require "rexml/document"
require "rexml/element"
require "test_framework/scheduler"
require "test_framework/report_builder"

class Controller
    def initialize(configuration)
        @configuration = configuration
        @testsuites = Array.new

        # create output directory
        FileUtils.mkdir_p(@configuration.output_directory)

        # fill the testsuites array with Testsuites according to configuration
        @testsuites_paths = TestsuiteExplorer.get_testsuites_paths(@configuration)
        @testsuites_paths.each do |testsuite_path|
            add_testsuite(testsuite_path)
        end
    end 

    def execute
        total_timer = Timer.new.start

        # load special Environment testsuite
        require 'test_framework/environment'
        output_file = @configuration.output_directory + "/#{Testsuite::Builder.name}"
        @environment = Testsuite::Builder.get_testsuite(Log.new(output_file), @configuration)

        # Execute startup and testcases of Environment before running any other testsuites
        environment_timer = Timer.new.start
        @environment.execute_startup
        @environment.execute_testcases
        @environment.duration = environment_timer.get_time

        # Only if startup and all testcases passed, execute testsuites
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

        environment_timer = Timer.new.start
        @environment.execute_cleanup
        @environment.duration += environment_timer.get_time

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

    def add_testsuite(testsuite)
        require testsuite
        output_file = @configuration.output_directory + "/#{Testsuite::Builder.name}"
        @testsuites << Testsuite::Builder.get_testsuite(Log.new(output_file), @configuration)
    end

    def plaintext_summary_report
        report = "Results:\n#{"-"}"
    end

    def run_testsuites_sequentially
        @testsuites.each do |testsuite|
            testsuite.execute
        end
    end

    def run_testsuites_concurrently
        scheduler = Scheduler.new(@testsuites)
        scheduler.run
    end
end