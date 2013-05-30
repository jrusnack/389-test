
require "test_framework/dsl"
require "389/directory_server"

testsuite "Basic" do

	startup do
		@directory_server = DirectoryServer.new
		@directory_server.setup
		result FAIL
	end

	testcase "tc01"
		with 1, 2
		with 3, 4
		with 5, 6
		run do |parm1, parm2|
			log "I am first testcase running with parameters #{parm1}, #{parm2}"
			@directory_server.start
			assert("DS should be running.", @directory_server.running?)
		end

	testcase "tc02"
		run do
			@directory_server.stop
			assert("DS should be running.", @directory_server.running?)
		end	

	cleanup do
		@directory_server.remove
		result PASS
	end
end