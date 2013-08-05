
require "test_framework/dsl"
require "389/directory_server"

testsuite "replication-bugzillas"
    options :parallelizable => :true
    testcases do

    startup do
        @master = DirectoryServer.get_instance(@log)
        @master.add_replication_manager
        @master.enable_changelog
        @master.enable_supplier('dc=example,dc=com', 1)
    end

    # The behaviour of modrdn for a tombstone entry is very inconsistent. Modrdn 
    # has two options: deleteoldrdn and newsuperior and the result is different 
    # for different combinations:
    #
    # deleteoldrdn: 1 NO newsuperior: ==> err=53 (unwilling to perform)
    # deleteoldrdn: 1 newsuperior: <dn> ==> err=53 (unwilling to perform)
    # deleteoldrdn: 0 NO newsuperior ==> err=1 (operations error)
    # deleteoldrdn: 0 newsuperior: <dn> ==> CRASH
    #
    # The crash has the side effect, that the entry is no longer accessable after 
    # restart, an attempt to repeat the operation gives err=32 (no such object)
    #
    # Fix Description:   client modrdns and modifies on tombstone entries should not be
    # accepted. Tombstones aer internally kept for eventual conflict resolution, normal
    # clients should not touch them.
    testcase 'bug974719'
        purpose 'rhds90 crash on tombstone modrdn'
        with 'tuser1', nil,                 1, 53
        with 'tuser2', nil,                 0, 53
        with 'tuser3', 'dc=example,dc=com', 1, 53
        with 'tuser4', 'dc=example,dc=com', 0, 53

        run do |user, new_superior, deleteoldrdn, expected_rc|
            # Add user
            log @master.add_user("uid=#{user},ou=people,dc=example,dc=com")

            # Delete him to create tombstone entry
            log @master.ldapdelete_r("uid=#{user},ou=people,dc=example,dc=com")

            # Get the nsuniqueid of the tombstone
            nsuniqueid = @master.ldapsearch_r(:base => "ou=people,dc=example,dc=com", \
                :filter => "(&(objectclass=nstombstone)(uid=#{user}))", :attributes => 'nsuniqueid').get_attr_value('nsuniqueid')
            log "nsuniqueid of tombstone is #{nsuniqueid}"

            # Create the input for ldapmodify
            input = <<-EOF
                dn: nsuniqueid=#{nsuniqueid}, uid=#{user},ou=people,dc=example,dc=com
                changetype: modrdn
                newrdn: nsuniqueid=#{nsuniqueid}
                deleteoldrdn: #{deleteoldrdn}
            EOF
            # If new_superior is specified (not nil), add it to the input
            if new_superior then
                input << "newSuperior: #{new_superior}"
            end

            # Try to modrdn and log the output
            log @master.ldapmodify_r(input)

            # Verify that returned return code is the same as expected return code
            assert_equal("Modrdn on tombstone should be refused with unwilling to perform.", expected_rc, $?.exitstatus)
        end

    cleanup do
        @master.remove if @master
    end
end