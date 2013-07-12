
require "test_framework/dsl"
require "389/directory_server"

testsuite "basic"
	options({ :parallelizable => :false })
	testcases do

	startup do
		@directory_server = DirectoryServer.new(@log, {:suffix => "dc=example, dc=com"})
		@directory_server.setup
		@directory_server.start
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
			log @directory_server.ldapsearch({:base => ' ', :scope => 'base', :other => '-LLL -x', :attributes => 'supportedLDAPVersion'})
			assert("Search should be successful with return code 0", $?.exitstatus == 0)
		end

	testcase "tc05"
		purpose "Try root DN bind"
		run do
			log @directory_server.ldapsearch_r({:base => "", :scope => 'base', :other => '-LLL -x', :attributes => 'supportedLDAPVersion'})
			assert("Search should be successful with return code 0", $?.exitstatus == 0)
		end

	testcase "tc06"
		purpose "Try adding new entry"
		with "tuser1"
		with "tuser2"
		run do |username|
			log @directory_server.add_user(username)
			log "Searching for added user #{username} ..."
			log @directory_server.ldapsearch_r(:base => "uid=#{username},dc=example,dc=com", :other => '-LLL')
			assert("User should be present on DS", $?.exitstatus == 0)
		end

	cleanup do
		@directory_server.remove
	end
end