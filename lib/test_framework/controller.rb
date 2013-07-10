
require "test_framework/testsuite"
require "rexml/document"
require "rexml/element"


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
		# load special Environment testsuite and run startup and all testcases
		require 'test_framework/environment'
		output_file = @configuration.output_directory + "/#{Testsuite::Builder.name}"
		@environment = Testsuite::Builder.get_testsuite(Log.new(output_file))
		@environment.execute_startup
		@environment.execute_testcases

		# execute all testsuites
		@testsuites.each do |testsuite|
			testsuite.execute
		end

		# run cleanup
		@environment.execute_cleanup
	end

	def write_reports
		write_xml_report(@configuration.xml_report_file) if @configuration.write_xml_report
		write_junit_report(@configuration.junit_report_file) if @configuration.write_junit_report
	end	

	private

	def add_testsuite(testsuite)
		require testsuite
		output_file = @configuration.output_directory + "/#{Testsuite::Builder.name}"
		@testsuites << Testsuite::Builder.get_testsuite(Log.new(output_file))
	end

	def write_xml_report(output_file)
		@xml_report = REXML::Document.new
		@xml_report << REXML::XMLDecl.new
		@testsuites.each do |testsuite|
			@xml_report.add(testsuite.to_xml)
		end
		File.open(output_file, 'w') {|file| @xml_report.write(file, 4)}
	end

	def write_junit_report(output_file)
		@junit_report = REXML::Document.new
		@junit_report << REXML::XMLDecl.new
		@testsuites.each do |testsuite|
			@junit_report.add(testsuite.to_junit_xml)
		end
		File.open(output_file, 'w') {|file| @junit_report.write(file, 4)}
	end
end