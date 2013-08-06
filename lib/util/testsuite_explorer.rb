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

module TestsuiteExplorer

    SELECT_ALL = :all
    SELECT_MANUALLY = :select_manually

    def self.get_testsuites_paths(configuration)
        if configuration.testsuites_to_run == nil
            return discover_testsuites(configuration.test_directory)
        else
            all_testsuites = discover_testsuites(configuration.test_directory)
            return filter_testsuites_to_run(all_testsuites, configuration)
        end
    end

    # Returns array of paths of all discovered testsuites
    def self.discover_testsuites(directory)
        testsuites_paths = Array.new
        # loop over all directories containing testsuites
        Dir.glob(directory + "/*") do |testsuite_directory|
            next if testsuite_directory == '.' or testsuite_directory == '..'
            # loop over all files within testsuite directory
            Dir.glob("#{testsuite_directory}/*") do |file|
                next if file == '.' or file == '..'
                # if file contains keyword 'testsuite', add it to the list of testsuites
                if File.readlines(file).grep(/testsuite/).size > 0
                    testsuites_paths << file
                end
            end
        end
        return testsuites_paths
    end

    # Given the array of paths to testsuites, returns array of paths of testsuites
    # that are to be run according to the configuration.testsuites_to_run
    def self.filter_testsuites_to_run(testsuites_paths, configuration)
        testsuites_to_run = Array.new
        testsuites_paths.each do |testsuite_file|
            name = File.readlines(testsuite_file).grep(/testsuite/)[0].gsub(/.*testsuite "(.*)"/,'\1').strip
            testsuites_to_run << testsuite_file if configuration.testsuites_to_run.include?(name)
        end
        return testsuites_to_run
    end

end