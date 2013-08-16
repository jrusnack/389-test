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

require "test_framework/dsl"
require "util/yum"

testsuite "environment" do

    # Prepares machine for running the tests
    startup do
        log Yum.install('389-ds-base')
    end

    before_upgrade do
        log Yum.remove('389-*')
        log Yum.install(@configuration.upgrade_from)
        log "Directory Server version before upgrade: #{DirectoryServer.version}"
    end

    after_upgrade do
        log Yum.install(@configuration.upgrade_to)
        log "Directory Server version after upgrade: #{DirectoryServer.version}"
    end

    # Checks to make sure machine is correctly set up
    testcase "check"
        run do
            sh "ping -w 2 -c 1 #{get_fqdn}"
            assert_equal("Machine should be able to ping it`s FQDN", $?, 0)
            assert("Directory Server rpm should be installed.", `rpm -qa` =~ /389-ds-base-[0-9]/)
        end

end