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

testsuite "replication-2master"
    options :parallelizable => :true
    testcases do

    startup do
        @master1 = DirectoryServer.get_instance(@log)
        @master1.add_replication_manager
        @master1.enable_changelog
        @master1.enable_supplier('dc=example,dc=com', 1)

        @master2 = DirectoryServer.get_instance(@log)
        @master2.add_replication_manager
        @master2.enable_changelog
        @master2.enable_consumer('dc=example,dc=com', 2)

        @master1.add_replication_agreement(@master2, 'agreement1', 'dc=example,dc=com')
        @master1.start_replication('agreement1', 'dc=example,dc=com')
        sleep 5
        log "Replication agreement:"
        log @master1.get_replication_agreement('agreement1',"dc=example, dc=com")
    end

    before_upgrade do
        @master1 = DirectoryServer.get_instance(@log)
        @master1.add_replication_manager
        @master1.enable_changelog
        @master1.enable_supplier('dc=example,dc=com', 1)

        @master2 = DirectoryServer.get_instance(@log)
        @master2.add_replication_manager
        @master2.enable_changelog
        @master2.enable_consumer('dc=example,dc=com', 2)

        @master1.add_replication_agreement(@master2, 'agreement1', 'dc=example,dc=com')
        @master1.start_replication('agreement1', 'dc=example,dc=com')
        sleep 5
        log "Replication agreement:"
        log @master1.get_replication_agreement('agreement1',"dc=example, dc=com")
        @master1.stop
        @master2.stop
    end

    after_upgrade do
        @master1.start
        @master2.start
    end

    testcase 'tc01'
        purpose "Verify replication - add user on master1 and check on master2"
        with 'uid=tuser,ou=people,dc=example,dc=com'
        run do |user|
            @master1.add_user(user)
            sleep 1
            log @master2.ldapsearch_r(:base => user, :other => '-LLL')
            assert_equal("User should be present on master2.", 0, $?.exitstatus)
        end

    cleanup do
        @master1.remove if @master1
        @master2.remove if @master2
    end
end