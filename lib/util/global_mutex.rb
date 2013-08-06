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

require 'util/os'
require 'fileutils'

class GlobalMutex
    include OS

    def initialize
        @lockfile = get_tmp_file
    end

    def acquire
        sleep (rand(2000) / 1000.0)
        while File.exists?(@lockfile)
            sleep (0.5 + rand(2000)/1000.0)
        end
        FileUtils.touch(@lockfile)
    end

    def release
        File.delete(@lockfile)
    end
end