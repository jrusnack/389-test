
require "test_framework/dsl"

testsuite Basic

	testcase tc01
		run do
			puts "I am first testcase"
		end

	testcase tc02
		run do
			puts "I am second testcase"
		end
