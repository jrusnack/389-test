
require "test_framework/testsuite"
require "rexml/document"
require "rexml/element"


class Controller

	def initialize
		@testsuites = Array.new
		@report = REXML::Document.new
		@report << REXML::XMLDecl.new
	end

	def add_testsuite(testsuite)
		require testsuite
		@testsuites << Testsuite::Builder.get_testsuite
	end

	def execute
		@testsuites.each do |testsuite| 
			testsuite.execute
			@report.add(testsuite.to_xml)
		end
	end

	def write_report(filepath)
		report_file = File.open(filepath,'w')
		@report.write(report_file, 4)
		report_file.close
	end
end