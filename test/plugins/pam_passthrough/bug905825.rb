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
require "389/directory_server"

testcase 'bug905825' do
    options :parallelizable => :true
    purpose 'PamConfig schema not updated during upgrade'
    depends_on 'bug:974719'

    startup do
        @ds = DirectoryServer.get_instance(@log)
    end

    before_upgrade do
        self.execute_startup
        @ds.stop
    end

    after_upgrade do
        @ds.start
    end

    check '01'
        run do
            pamConfig = sh "sudo cat #{@ds.schema_dir}/60pam-plugin.ldif | grep pamConfig"
            assert("pamConfig should contain 'cn'", pamConfig.include?('cn'))
            assert("pamConfig should contain pamFiler", pamConfig.include?('pamFilter'))
        end

    cleanup do
        @ds.remove if @ds
    end
end