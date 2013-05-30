
require "test_framework/testsuite"
require "rexml/document"
require "rexml/element"


class Controller

	def initialize(report_directory_path)
		@testsuites = Array.new
		@report_directory_path = report_directory_path
	end

	def add_testsuite(testsuite)
		require testsuite
		@testsuites << Testsuite::Builder.get_testsuite
	end

	def execute
		@testsuites.each do |testsuite|
			testsuite.execute
		end
	end

	def write_xml_report		
		@xml_report = REXML::Document.new
		@xml_report << REXML::XMLDecl.new
		@testsuites.each do |testsuite|
			@xml_report.add(testsuite.to_xml)
		end
		File.open(@report_directory_path + "/results.xml", 'w') {|file| @xml_report.write(file, 4)}
	end

	def write_junit_report
		@junit_report = REXML::Document.new
		@junit_report << REXML::XMLDecl.new
		@testsuites.each do |testsuite|
			@junit_report.add(testsuite.to_junit_xml)
		end
		File.open(@report_directory_path + "/junit.xml", 'w') {|file| @junit_report.write(file, 4)}
	end
end