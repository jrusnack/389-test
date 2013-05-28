

require "test_framework/testsuite"

class TestsuiteBuilder

	def self.name(name)
		@@name = name
		@@testcases = Array.new
	end

	def self.add_testcase(testcase)
		@@testcases << testcase
	end

	def self.create_testsuite
		testsuite = Testsuite.new(@@name, @@testcases)
		@@name = nil
		@@testcases = nil
		return testsuite
	end
end