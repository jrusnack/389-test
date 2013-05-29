
require "test_framework/testcase"

class Testsuite

	class Builder
		def self.build(name, &block)
			@@testsuite = Testsuite.new(name)
			@@testsuite.instance_eval(&block)
		end

		def self.get_testsuite
			@@testsuite
		end
	end

	def initialize(name)
		@name = name
		@testcases = Array.new
		@startup = nil
		@cleanup = nil
	end

	def execute
		puts "=== Startup of #{name} ==="
		@startup.call if @startup != nil
		puts "=== Executing testcases ==="
		@testcases.each {|t| t.execute}
		puts "=== Cleanup of #{name} ==="
		@cleanup.call if @cleanup != nil
	end

	private

	def startup(&block)
		@startup = block
	end

	def testcase(name)
		Testcase::Builder.new(name)
	end

	def with(*parameters)
		Testcase::Builder.add_parameters(parameters)
	end

	def run(&block)
		@testcases << Testcase::Builder.create_testcase(&block)
	end

	def cleanup(&block)
		@cleanup = block
	end
end