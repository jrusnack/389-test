
require "test_framework/testcase"

class TestcaseBuilder
	def self.name= (name)
		@@name = name
		@@parameters = Array.new
	end

	def self.add_parameters(parameters)
		@@parameters.concat(parameters)
	end

	def self.create_testcase(&block)
		testcase = Testcase.new(@@name, @@parameters, &block)
		@@name = nil
		@@parameters = nil
		return testcase
	end
end