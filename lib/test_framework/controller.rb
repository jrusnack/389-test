
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
		@environment = Testsuite::Builder.get_testsuite
		@environment.execute_startup(@configuration, @configuration.output_directory)
		@environment.execute_testcases

		@testsuites.each do |testsuite|
			output_directory = @configuration.output_directory + "/#{testsuite.name}"
			FileUtils.mkdir_p(output_directory)
			testsuite.execute(@configuration, output_directory)
		end
		# run cleanup
		@environment.execute_cleanup
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

	private

	def add_testsuite(testsuite)
		require testsuite
		@testsuites << Testsuite::Builder.get_testsuite
	end
end