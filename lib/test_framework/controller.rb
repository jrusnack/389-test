
require "test_framework/testsuite"
require "rexml/document"
require "rexml/element"


class Controller

	def initialize
		@testsuites = Array.new
	end

	def add_testsuite(testsuite)
		require testsuite
		@testsuites << Testsuite::Builder.get_testsuite
	end

	def execute(output_dir=nil)
		@testsuites.each do |testsuite|
			output_file = output_dir ? output_dir + "/#{testsuite.name}" : nil
			testsuite.execute(output_file)
		end
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