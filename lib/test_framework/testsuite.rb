
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
		puts "=== Startup of #{@name} ==="
		@startup.execute if @startup != nil
		puts "=== Executing testcases ==="
		@testcases.each do |testcase|
			@current_testcase = testcase
			testcase.execute
		end
		puts "=== Cleanup of #{@name} ==="
		@cleanup.execute if @cleanup != nil
	end

	def to_xml
		xml = REXML::Element.new("testsuite")
		xml.add(REXML::Element.new("name").add_text(@name))
		if startup
			xml.add(@startup.to_xml)
		end
		@testcases.each do |testcase|
			xml.add(testcase.to_xml)
		end
		if cleanup
			xml.add(@cleanup.to_xml)
		end
		return xml
	end

	private

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

	def log(message)
		@current_testcase.output << "\n#{message}"
	end
end