
require "test_framework/testcase"
require "test_framework/failure"
require "rexml/element"
require 'util/log'
require 'util/os'
require 'ldap/ldap'

class Testsuite
	include LogMixin
	include OS
	include Ldap
	attr_reader :name, :passed, :failed, :skipped, :options

	class Builder

		def self.name=(name)
			@@name = name
		end

		def self.options=(options)
			@@options = options
		end

		def self.testcases(&block)
			@@block = block
		end

		def self.name
			@@name
		end

		def self.get_testsuite(log, configuration)
			testsuite = Testsuite.new(@@name, log, @@options, configuration)
			# Probably the ugliest thing ..
			testsuite.instance_eval(&@@block)
			return testsuite
		end
	end

	def initialize(name, log, options, configuration)
		@name = name
		@log = log
		@options = options
		@configuration = configuration
		@testcases = Array.new
		@startup = nil
		@cleanup = nil
		@passed = Array.new
		@failed = Array.new
		@skipped = Array.new
	end

	def execute
		execute_startup
		execute_testcases
		execute_cleanup
	end

	def execute_startup
		log(testsuite_header)
		run_testcase(@startup) if @startup != nil
	end

	def execute_testcases
		# skip all if startup failed
		if @startup.result == Testcase::FAIL
			@skipped.concat(@testcases)
			return
		end

		@testcases.each do |testcase|
			run_testcase(testcase)
		end
	end

	def execute_cleanup
		run_testcase(@cleanup) if @cleanup != nil
		log(testsuite_footer)
	end

	def run_testcase(testcase)
		begin
			@log.testcase = testcase
			log(testcase.header)
			testcase.execute
			# if no exception was raised, testcase passed
			testcase.result = Testcase::PASS
			@passed << testcase
			log(testcase.footer)
			@log.testcase = nil
			return true
		rescue RuntimeError, Failure => error
			testcase.result = Testcase::FAIL
			testcase.error = error
			@failed << testcase
			log_error(error)
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

	def testsuite_header
		"#"*20 + " Testsuite #{@name} " + "#"*20
	end

	def testsuite_footer
		"\n" + "#"*20 + " End of #{@name} " + "#"*20
	end

	#########################################
	# Functions for setting up the testcase #

	def startup(&block)
		@startup = Testcase.new("startup", @name, nil, nil, &block)
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

	def purpose(purpose)
		Testcase::Builder.add_purpose(purpose)
	end

	def run(&block)
		@testcases.concat(Testcase::Builder.create_testcases(&block))
	end

	def cleanup(&block)
		@cleanup = Testcase.new("cleanup", @name, nil, nil, &block)
		@cleanup.result = Testcase::PASS 	# Passes by default
	end

	###########################
	# Functions used in tests #

	def assert(message, condition)
		if condition == true
			@log.info(message, 'PASS')
		else
			raise Failure.new(message)
		end
	end

	def assert_equal(message, expected, actual)
		if expected == actual
			@log.info(message, 'PASS')
		else
			raise Failure.new(message + " Expected: #{expected}, but was #{actual}.")
		end
	end
end