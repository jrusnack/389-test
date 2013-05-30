
require "test_framework/testcase"
require "test_framework/failure"
require "rexml/element"

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
		@passed = Array.new
		@failed = Array.new
		@skipped = Array.new
	end

	def execute
		puts header
		if @startup != nil
			run_testcase(@startup)
			if @startup.result == Testcase::FAIL
				@skipped.concat(@testcases)
				run_testcase(@cleanup)
				puts footer
				return
			end
		end

		@testcases.each do |testcase|
			run_testcase(testcase)
		end

		if @cleanup != nil
			run_testcase(@cleanup)
		end
		puts footer
	end

	def run_testcase(testcase)
		begin
			@current_testcase = testcase
			log(testcase.header)
			testcase.execute
			testcase.result = Testcase::PASS
			@passed << testcase
			log(testcase.footer)
			return true
		rescue RuntimeError, Failure => error
			testcase.result = Testcase::FAIL
			testcase.error = error
			@failed << testcase
			log("#{error.class}: #{error.message}\n#{error.backtrace.join("\n")}")
			log(testcase.footer)
			return false
		end
	end

	def to_xml
		testsuite_xml = REXML::Element.new("testsuite")
		testsuite_xml.add(REXML::Element.new("name").add_text(@name))
		if @startup
			testsuite_xml.add(@startup.to_xml)
		end
		@testcases.each do |testcase|
			testsuite_xml.add(testcase.to_xml)
		end
		if @cleanup
			testsuite_xml.add(@cleanup.to_xml)
		end
		return testsuite_xml
	end

	def to_junit_xml
		testsuite_xml = REXML::Element.new("testsuite")
		testsuite_xml.add_attribute('name', @name)
		if @startup
			testsuite_xml.add(@startup.to_junit_xml)
		end
		@testcases.each do |testcase|
			testsuite_xml.add(testcase.to_junit_xml)
		end
		if @cleanup
			testsuite_xml.add(@cleanup.to_junit_xml)
		end
		return testsuite_xml
	end

	private

	def header
		"=== Testsuite #{@name} ==="
	end

	def footer
		"=== End of #{@name} ==="
	end

	#########################################
	# Functions for setting up the testcase #

	def startup(&block)
		@startup = Testcase.new("startup", @name, nil, &block)
		@startup.result = Testcase::PASS 	# Passes by default
	end

	def testcase(testcase_name)
		if testcase_name == "startup" || testcase_name == "cleanup"
			raise ArgumentError.new("Invalid testcase name #{name}")
		end
		Testcase::Builder.new(testcase_name, @name)
	end

	def with(*parameters)
		Testcase::Builder.add_parameters(parameters)
	end

	def run(&block)
		@testcases.concat(Testcase::Builder.create_testcases(&block))
	end

	def cleanup(&block)
		@cleanup = Testcase.new("cleanup", @name, nil, &block)
		@cleanup.result = Testcase::PASS 	# Passes by default
	end

	###########################
	# Functions used in tests #

	def log(message)
		@current_testcase.output << "\n#{message}"
		puts message
	end

	def assert(message, condition)
		if condition != true
			raise Failure.new(message)
		end
	end
end