
require "test_framework/dsl"
require "389/directory_server"

testsuite "basic" do

	startup do
		@directory_server = DirectoryServer.new(@log)
		@directory_server.setup
		@directory_server.start
		assert("DS should be running.", @directory_server.running?)
	end

	testcase "tc01"
		with "cn=config", "nsslapd-disk-monitoring"
		with "dc=example,dc=com", "objectClass"
		run do |parm1, parm2|
			log "I am first testcase running with parameters #{parm1}, #{parm2}"
			log @directory_server.ldapsearch_r({:base => parm1, :scope => 'base', :attributes => parm2})
		end

	testcase "tc02"
		run do
			@directory_server.stop
			assert("DS should be running.", @directory_server.running?)
		end

	cleanup do
		@directory_server.remove
	end
end