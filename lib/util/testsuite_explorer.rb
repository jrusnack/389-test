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
        return discover_testsuites(configuration.test_directory)
    end

    # Returns array of paths of all discovered testsuites
    def self.discover_testsuites(directory)
        testsuites_paths = Array.new
        # recursively loop over all directories containing testsuites
        Dir.glob(directory + "/*") do |filename|
            next if filename == '.' or filename == '..'
            # If filename is regular file and contians testcases, add to paths
            if File.file?(filename) && File.readlines(filename).grep(/testcase/).size > 0
                testsuites_paths << filename
            end
            # If filename is a directory, search recursively
            if File.directory?(filename)
                testsuites_paths.concat(self.discover_testsuites(filename))
            end
        end
        return testsuites_paths
    end

end