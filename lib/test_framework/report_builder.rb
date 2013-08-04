
class ReportBuilder

	# Expects array of testsuites
	def initialize(environment, testsuites)
		@environment = environment
		@testsuites = testsuites
	end

	# Returns XML report as REXML::Document
	def get_xml_report
		xml_report = REXML::Document.new
        xml_report << REXML::XMLDecl.new
        results = REXML::Element.new("results")
        results.add(@environment.to_xml)
        @testsuites.each do |testsuite|
            results.add(testsuite.to_xml)
        end
        xml_report.add(results)
        return xml_report
	end

	# Returns XML report in JUnit format as REXML::Document
	def get_junit_report
		junit_report = REXML::Document.new
        junit_report << REXML::XMLDecl.new
        testsuites_xml = REXML::Element.new("testsuites")
        testsuites_xml.add(@environment.to_junit_xml)
        @testsuites.each do |testsuite|
            testsuites_xml.add(testsuite.to_junit_xml)
        end
        junit_report.add(testsuites_xml)
        return junit_report
	end
end