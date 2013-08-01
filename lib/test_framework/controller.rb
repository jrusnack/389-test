
require "test_framework/testsuite"
require "rexml/document"
require "rexml/element"
require "test_framework/scheduler"

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
		# load special Environment testsuite
		require 'test_framework/environment'
		output_file = @configuration.output_directory + "/#{Testsuite::Builder.name}"
		@environment = Testsuite::Builder.get_testsuite(Log.new(output_file), @configuration)
		
		# Execute startup and testcases of Environment before running any other testsuites
		@environment.execute_startup
		@environment.execute_testcases

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
		
		@environment.execute_cleanup
	end

	def write_reports
		if @configuration.write_xml_report then
			write_xml_report(@configuration.output_directory + "/" + @configuration.xml_report_file)
		end
		if @configuration.write_junit_report
			write_junit_report(@configuration.output_directory + "/" + @configuration.junit_report_file)
		end
	end	

	private

	def add_testsuite(testsuite)
		require testsuite
		output_file = @configuration.output_directory + "/#{Testsuite::Builder.name}"
		@testsuites << Testsuite::Builder.get_testsuite(Log.new(output_file), @configuration)
	end

	def write_xml_report(output_file)
		@xml_report = REXML::Document.new
		@xml_report << REXML::XMLDecl.new
		results_xml = REXML::Element.new("results")
		@testsuites.each do |testsuite|
			results_xml.add(testsuite.to_xml)
		end
		@xml_report.add(results_xml)
		File.open(output_file, 'w') {|file| @xml_report.write(file, 4)}
	end

	def write_junit_report(output_file)
		@junit_report = REXML::Document.new
		@junit_report << REXML::XMLDecl.new
		testsuites_xml = REXML::Element.new("testsuites")
		@testsuites.each do |testsuite|
			testsuites_xml.add(testsuite.to_junit_xml)
		end
		@junit_report.add(testsuites_xml)
		File.open(output_file, 'w') {|file| @junit_report.write(file, 4)}
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