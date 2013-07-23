
require "test_framework/dsl"
require "389/directory_server"

testsuite "replication"
	options :parallelizable => :false
	testcases do

	startup do
		@master1 = DirectoryServer.get_instance(@log)
		@master2 = DirectoryServer.get_instance(@log)
	end

	testcase "tc01"
		purpose "Add replication managers"
		run do
			@master1.add_replication_manager
			@master2.add_replication_manager
		end

	testcase "tc02"
		purpose "Enable changelogs"
		run do
			@master1.enable_changelog
			@master2.enable_changelog
		end

	cleanup do
		@master1.remove
		@master2.remove
	end
end