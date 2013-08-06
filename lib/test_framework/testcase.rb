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

require 'util/dependency_checker'

class Testcase
    attr_reader :name
    attr_accessor  :output, :result, :error, :duration

    UNKNOWN = "UNKNOWN"
    PASS    = "PASS"
    FAIL    = "FAIL"

    class Builder
        def self.new(name, testsuite_name)
            @@name = name
            @@testsuite_name = testsuite_name
            @@purpose = nil
            @@dependencies = nil
            @@all_parameters = Array.new
        end

        def self.add_parameters(parameters)
            if parameters.size == 1
                @@all_parameters.concat(parameters)
            else
                @@all_parameters.concat([parameters]) 
            end
        end

        def self.add_purpose(purpose)
            @@purpose = purpose
        end

        def self.add_dependencies(dependencies)
            @@dependencies = dependencies
        end

        def self.create_testcases(&block)
            if @@all_parameters.size == 0
                return [Testcase.new(@@name, @@testsuite_name, @@purpose, nil, @@dependencies, &block)]
            else
                testcases = Array.new
                @@all_parameters.each do |parameters|
                    testcases << Testcase.new(@@name, @@testsuite_name, @@purpose, parameters, @@dependencies, &block)
                end
                return testcases
            end
        end
    end

    def initialize(name, testsuite_name, purpose, parameters, dependencies, &code)
        @name = name
        @purpose = purpose
        @testsuite_name = testsuite_name
        @parameters = parameters
        @dependencies = dependencies
        @code = code
        @output = ""
        @error = nil
        @result = UNKNOWN
        @duration = nil
    end

    # Executes the associated code, which will run within the context of caller,
    # not testcase.
    def execute
        @parameters ? @code.call(@parameters) : @code.call
    end

    def met_dependencies?
        return true if @dependencies == nil
        result = true
        @dependencies.each do |dep|
            result = false unless DependencyChecker.met_dependency?(dep)
        end
        return result
    end

    def to_xml
        testcase_xml = REXML::Element.new("testcase")
        testcase_xml.add(REXML::Element.new("name").add_text(@name))
        testcase_xml.add(REXML::Element.new("parameters").add_text(@parameters.inspect))
        testcase_xml.add(REXML::Element.new("result").add_text(@result))
        testcase_xml.add(REXML::Element.new("output").add_text(REXML::CData.new(@output)))
        return testcase_xml
    end

    def to_junit_xml
        testcase_xml = REXML::Element.new('testcase')
        if @parameters then
            testcase_xml.add_attribute('name', @name + " with " + @parameters.inspect)
        else
            testcase_xml.add_attribute('name', @name)
        end
        testcase_xml.add_attribute('classname', @testsuite_name)
        testcase_xml.add_attribute('time', @duration)
        if @result == FAIL
            if @error.class == Failure
                error_xml = REXML::Element.new('failure')
            else
                error_xml = REXML::Element.new('error')
            end
            error_xml.add_attribute('type', @error.class)
            error_xml.add_attribute('message', @error.message)
            error_xml.add_text(REXML::CData.new(@output))
            testcase_xml.add(error_xml)
        elsif @result == UNKNOWN
            testcase_xml.add(REXML::Element.new('skipped'))
        end
        return testcase_xml
    end

    def store_results
        return Marshal.dump([@output, @error, @result, @duration])
    end

    def load_results(string)
        @output, @error, @result, @duration = Marshal.load(string)
    end

    def header
        output = "\n" + ":"*65 + "\nTESTCASE:   #{@name}"
        output << "\nPURPOSE:    #{@purpose}" if @purpose
        output << "\nPARAMETERS: #{@parameters}" if @parameters
        output << "\n" + ":"*65
    end

    def footer
        return "RESULT: #{@result}"
    end

    def unique_name
        @parameters ? "#{@name}-#{@parameters.inspect}" : "#{name}"
    end
end