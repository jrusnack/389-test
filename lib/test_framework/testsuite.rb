
require "test_framework/testcase"
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
	end

	def execute
		puts header
		if @startup != nil
			run_testcase(@startup)
			if @startup.result == Testcase::FAIL
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
			log(testcase.footer)
			return true
		rescue RuntimeError => error
			testcase.result = Testcase::FAIL
			log("#{error.class}: #{error.message}\n#{error.backtrace.join("\n")}")
			return false
		end
	end

	def to_xml
		xml = REXML::Element.new("testsuite")
		xml.add(REXML::Element.new("name").add_text(@name))
		if @startup
			xml.add(@startup.to_xml)
		end
		@testcases.each do |testcase|
			xml.add(testcase.to_xml)
		end
		if @cleanup
			xml.add(@cleanup.to_xml)
		end
		return xml
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
		@startup = Testcase.new("startup", nil, &block)
	end

	def testcase(name)
		if name == "startup" || name == "cleanup"
			raise ArgumentError.new("Invalid testcase name #{name}")
		end
		Testcase::Builder.new(name)
	end

	def with(*parameters)
		Testcase::Builder.add_parameters(parameters)
	end

	def run(&block)
		@testcases.concat(Testcase::Builder.create_testcases(&block))
	end

	def cleanup(&block)
		@cleanup = Testcase.new("cleanup", nil, &block)
	end

	###########################
	# Functions used in tests #

	def log(message)
		@current_testcase.output << "\n#{message}"
		puts message
	end

	def assert(condition)
		if condition
			@current_testcase.result = Testcase::PASS if @current_testcase.result != Testcase::FAIL
		else
			@current_testcase.result = Testcase::FAIL
			log("FAIL: \"#{condition}\" not TRUE")
		end
	end

	def result(result)
		@current_testcase.result = result
	end
end