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

class ReportBuilder

	# Expects array of testsuites
	def initialize(environment, testsuites, duration)
		@environment = environment
		@testsuites = testsuites
        @duration = duration
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

    def plaintext_summary_report
        report = "\n"
        longest_name = get_longest_testsuite_name
        format = "%-#{longest_name + 1}s  %6s  %8s  %6s  %8s  %7s  %9s\n"
        report << sprintf(format,"Testsuite","Passed", "Passed %", "Failed", "Failed %", "Skipped", "Skipped %")
        report << "-"*(57 + longest_name) << "\n"

        report << sprintf(format, @environment.name, @environment.passed_count, 
            @environment.passed_percent.to_s[0..4], @environment.failed_count,
            @environment.failed_percent.to_s[0..4], @environment.skipped_count,
            @environment.skipped_percent.to_s[0..4])
        total_passed = @environment.passed_count
        total_failed = @environment.failed_count
        total_skipped = @environment.skipped_count
        total_tests = @environment.testcases_count
        @testsuites.each do |testsuite|
            next if testsuite.executed? == false
            report << sprintf(format, testsuite.name, testsuite.passed_count, 
            testsuite.passed_percent.to_s[0..4], testsuite.failed_count, testsuite.failed_percent.to_s[0..4], 
            testsuite.skipped_count, testsuite.skipped_percent.to_s[0..4])
            total_passed += testsuite.passed_count
            total_failed += testsuite.failed_count
            total_skipped += testsuite.skipped_count
            total_tests += testsuite.testcases_count
        end
        report << "-"*(57 + longest_name) << "\n"
        report << sprintf(format, "Total", total_passed, (total_passed*100/Float(total_tests)).to_s[0..4], 
            total_failed, (total_failed*100/Float(total_tests)).to_s[0..4], total_skipped,
            (total_skipped*100/Float(total_tests)).to_s[0..4])
        report << "\nDuration: #{@duration} s\n"
        return report
    end

    def get_longest_testsuite_name
        max = 11 # length of 'environment'
        @testsuites.each do |testsuite|
            if testsuite.name.size > max then
                max = testsuite.name.size
            end
        end
        return max
    end
end