

require "test_framework/dsl"

testsuite "environment" do

	# Prepares machine for running the tests
	startup do

	end

	# Checks to make sure machine is correctly set up
	testcase "check"
		run do
			assert("Directory Server rpm should be installed.",	
				sh("rpm -qa | grep 389-ds-base").include?("389-ds-base"))
		end

end