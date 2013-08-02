

require "test_framework/dsl"

testsuite "environment" 
    testcases do

    # Prepares machine for running the tests
    startup do
        sh "sudo yum -y install 389-ds-base"
    end

    # Checks to make sure machine is correctly set up
    testcase "check"
        run do
            sh "ping -w 2 -c 1 #{get_fqdn}"
            assert_equal("Machine should be able to ping it`s FQDN", $?, 0)
            assert("Directory Server rpm should be installed.", `rpm -qa` =~ /389-ds-base-[0-9]/)
        end

end