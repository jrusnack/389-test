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

require 'util/testsuite_explorer'

class Configuration

    def initialize
        ####################################################################################
        # These are default values of options used when no specific value is set manually

        # Directories
        @root_directory     = File.expand_path("../../../", Pathname.new(__FILE__).realpath)
        @output_directory   = "#{@root_directory}/output/#{Time.now.strftime("%Y.%m.%d-%H:%M")}"
        @test_directory     = "#{@root_directory}/test"

        # Run all testsuites by default
        @testsuites_to_run  = nil

        # Reports
        @write_xml_report   = true
        @write_junit_report = true
        @xml_report_file    = "results.xml"
        @junit_report_file  = "junit.xml"

        # Execute multiple testsuites concurrently by default
        @execution = :parallel
        # @execution = :sequential

        ####################################################################################

        # Defined getters and setters for all instance variables
        instance_variables.each do |variable|
            variable = variable[1..-1]
            instance_eval("def #{variable};@#{variable};end")
            instance_eval("def #{variable}=(value);@#{variable}=value;end")
        end
    end
end