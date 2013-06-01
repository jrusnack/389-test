
class Testcase

	attr_accessor :output, :result, :error

	UNKNOWN = "UNKNOWN"
	PASS 	= "PASS"
	FAIL	= "FAIL"

	class Builder
		def self.new(name, testsuite_name)
			@@name = name
			@@testsuite_name = testsuite_name
			@@all_parameters = Array.new
		end

		def self.add_parameters(parameters)
			@@all_parameters.concat([parameters])
		end

		def self.create_testcases(&block)
			if @@all_parameters.size == 0
				return [Testcase.new(@@name, @@testsuite_name, nil, &block)]
			else
				testcases = Array.new
				@@all_parameters.each do |parameters|
					testcases << Testcase.new(@@name, @@testsuite_name, parameters, &block)
				end
				return testcases
			end
		end
	end

	def initialize(name, testsuite_name, parameters, &code)
		@name = name
		@testsuite_name = testsuite_name
		@parameters = parameters
		@code = code
		@output = ""
		@error = nil
		@result = UNKNOWN
	end

	# Executes the associated code, which will run within the context of caller,
	# not testcase.
	def execute
		@parameters ? @code.call(@parameters) : @code.call
	end

	def to_xml
		testcase_xml = REXML::Element.new("testcase")
		testcase_xml.add(REXML::Element.new("name").add_text(@name))
		testcase_xml.add(REXML::Element.new("parameters").add_text(@parameters.inspect))
		testcase_xml.add(REXML::Element.new("result").add_text(@result))
		testcase_xml.add(REXML::Element.new("output").add_text(REXML::CData.new(@output)))
		return testcase_xml
	end

	def to_junit_xml
		testcase_xml = REXML::Element.new('testcase')
		testcase_xml.add_attribute('name', @name)
		testcase_xml.add_attribute('classname', @testsuite_name)
		if @result == FAIL
			if @error.class == Failure
				error_xml = REXML::Element.new('failure')
			else
				error_xml = REXML::Element.new('error')
			end
			error_xml.add_attribute('type', @error.class)
			error_xml.add_attribute('message', @error.message)
			error_xml.add_text(REXML::CData.new(@output))
			testcase_xml.add(error_xml)
		elsif @result == UNKNOWN
			testcase_xml.add(REXML::Element.new('skipped'))
		end
		return testcase_xml
	end

	def header
		if @parameters
			return "-- Running test #{@name} with parameters #{@parameters} --\n"
		else
			return "-- Running test #{@name} --\n"
		end
	end

	def footer
		if @parameters
			return "-- End of test #{@name} with parameters #{@parameters} --\n" + \
				   "-- Result: #{@result} --\n\n"
		else
			return "-- End of test #{@name} --\n" + \
			       "-- Result: #{@result} --\n\n"
		end
	end
end