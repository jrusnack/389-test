
require "test_framework/testsuite"
require "rexml/document"
require "rexml/element"


class Controller

	def initialize(report_directory_path)
		@testsuites = Array.new
		@xml_report = REXML::Document.new
		@xml_report << REXML::XMLDecl.new
		@report_directory_path = report_directory_path
	end

	def add_testsuite(testsuite)
		require testsuite
		@testsuites << Testsuite::Builder.get_testsuite
	end

	def execute
		@testsuites.each do |testsuite|
			testsuite.execute
			@xml_report.add(testsuite.to_xml)
		end
	end

	def write_report
		File.open(@report_directory_path + "/results.xml", 'w') {|file| @xml_report.write(file, 4)}
	end
end