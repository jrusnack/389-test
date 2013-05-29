
require "test_framework/testsuite"

class Controller

	def initialize
		@testsuites = Array.new
	end

	def add_testsuite(testsuite)
		require testsuite
		@testsuites << Testsuite::Builder.get_testsuite
	end

	def execute
		@testsuites.each {|t| t.execute}
	end
end