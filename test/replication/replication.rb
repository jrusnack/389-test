
require "test_framework/dsl"
require "389/directory_server"

testsuite "replication"
	options :parallelizable => :true
	testcases do

	startup do
		@master1 = DirectoryServer.get_instance(@log)
		@master1.add_replication_manager
		@master1.enable_changelog
		@master1.enable_supplier('dc=example,dc=com', 1)
	end

	testcase "bug974719"
		purpose "rhds90 crash on tombstone modrdn"
		# Specify data that will be fed to the testcase
		with 'tuser1', nil, 				1, 53
		with 'tuser2', nil, 				0, 53
		with 'tuser3', 'dc=example,dc=com', 1, 53
		with 'tuser4', 'dc=example,dc=com', 0, 53
		run do |user, new_superior, deleteoldrdn, expected_rc|
			# Add user
			log @master1.add_user("uid=#{user},ou=people,dc=example,dc=com")

			# Delete him to create tombstone entry
			log @master1.ldapdelete_r("uid=#{user},ou=people,dc=example,dc=com")

			# Get the nsuniqueid of the tombstone
			nsuniqueid = @master1.ldapsearch_r(:base => "ou=people,dc=example,dc=com", \
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
			log @master1.ldapmodify_r(input)

			# Verify that returned return code is the same as expected return code
			assert_equal("Modrdn on tombstone should be refused with unwilling to perform.", expected_rc, $?.exitstatus)
		end

	cleanup do
		@master1.remove
	end
end