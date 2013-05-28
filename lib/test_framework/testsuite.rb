
require "test_framework/testcase_builder"

class Testsuite

	def initialize(name, testcases)
		@name = name
		@testcases = testcases
	end

	def execute
		puts "=== Executing testsuite #{@name} ==="
		@testcases.each {|t| t.execute}
	end	
end