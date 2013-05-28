
require "test_framework/testsuite_builder"

class Controller

	def initialize
		@testsuites = Array.new
	end

	def add_testsuite(testsuite)
		require testsuite
		@testsuites << TestsuiteBuilder.create_testsuite
	end

	def execute
		@testsuites.each {|t| t.execute}
	end
end