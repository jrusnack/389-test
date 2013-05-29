
require "test_framework/dsl"

testsuite "Basic" do

	startup do
		puts "starting up"
	end

	testcase "tc01"
		with 1, 2
		with 3, 4
		with 5, 6
		run do |parm1, parm2|
			log "I am first testcase running with parameters #{parm1}, #{parm2}"
		end

	testcase "tc02"
		run do
			puts "I am second testcase"
		end	

	cleanup do
		puts "cleaning up"
	end
end