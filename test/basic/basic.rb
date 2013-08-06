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

SUFFIX="dc=example,dc=com"

testsuite "basic"
    options :parallelizable => :true 
    testcases do

    startup do
        @directory_server = DirectoryServer.get_instance(@log, :suffix => SUFFIX)
        assert("DS should be running.", @directory_server.running?)
    end

    testcase "tc01"
        purpose "Stop Directory server instance"
        run do
            @directory_server.stop
            assert("DS should be stopped.", ! @directory_server.running?)
        end

    testcase "tc02"
        purpose "Start Directory server instance"
        run do
            @directory_server.start
            assert("DS should be running.", @directory_server.running?)
        end 

    testcase "tc03"
        purpose "Restart Directory server instance"
        run do
            @directory_server.restart
            assert("DS should be running.", @directory_server.running?)
        end

    testcase "tc04"
        purpose "Try anonymous bind"
        run do
            log @directory_server.ldapsearch(:base => ' ', :scope => 'base', :other => '-LLL -x', :attributes => 'supportedLDAPVersion')
            assert_equal("Search should be successful with return code 0", 0, $?.exitstatus)
        end

    testcase "tc05"
        purpose "Try root DN bind"
        run do
            log @directory_server.ldapsearch_r(:base => "", :scope => 'base', :other => '-LLL -x', :attributes => 'supportedLDAPVersion')
            assert_equal("Search should be successful with return code 0", 0, $?.exitstatus)
        end

    testcase "tc06"
        purpose "Try adding new user"
        with "uid=tuser1, ou=people, #{SUFFIX}"
        with "cn=tuser2, ou=people, #{SUFFIX}"
        run do |user|
            log @directory_server.add_user(user)
            log "Searching for added user #{user} ..."
            log @directory_server.ldapsearch_r(:base => user, :other => '-LLL')
            assert_equal("User should be present on DS", 0, $?.exitstatus)
        end

    testcase "tc07"
        purpose "Try modifying user - adding attribute"
        with "uid=tuser1, ou=people, #{SUFFIX}"
        with "cn=tuser2, ou=people, #{SUFFIX}"
        run do |user|
            mail = "#{get_rdn(user)}@example.com"
            log @directory_server.ldapmodify_r <<-EOF
                dn: #{user}
                changetype: modify
                add: mail
                mail: #{mail}
            EOF
            value = @directory_server.get_attribute('mail', user)
            assert_equal("Attribute mail should be added", mail, value)
        end

    testcase "tc08"
        purpose "Try modifying user - replacing attribute"
        with "uid=tuser1, ou=people, #{SUFFIX}"
        with "cn=tuser2, ou=people, #{SUFFIX}"
        run do |user|
            rdn = get_rdn(user)
            log @directory_server.ldapmodify_r <<-EOF
                dn: #{user}
                changetype: modify
                replace: sn
                sn: #{rdn}-modified
            EOF
            value = @directory_server.get_attribute('sn', user)
            assert_equal("Value of sn should be modified.", "#{rdn}-modified", value)
        end

    testcase "tc09"
        purpose "Try modifying user - deleting attribute"
        with "uid=tuser1, ou=people, #{SUFFIX}"
        with "cn=tuser2, ou=people, #{SUFFIX}"
        run do |user|
            log @directory_server.ldapmodify_r <<-EOF
                dn: #{user}
                changetype: modify
                delete: mail
            EOF
            value = @directory_server.get_attribute('mail', user)
            assert_equal("Value of sn should be deleted.", nil, value)
        end

    cleanup do
        if @directory_server
            @directory_server.stop
            @directory_server.remove
        end
    end
end