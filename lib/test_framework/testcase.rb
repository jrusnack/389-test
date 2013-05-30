
class Testcase

	attr_accessor :output, :result

	UNKNOWN = "UNKNOWN"
	PASS 	= "PASS"
	FAIL	= "FAIL"

	class Builder
		def self.new(name)
			@@name = name
			@@all_parameters = Array.new
		end

		def self.add_parameters(parameters)
			@@all_parameters.concat([parameters])
		end

		def self.create_testcases(&block)
			if @@all_parameters.size == 0
				return [Testcase.new(@@name, nil, &block)]
			else
				testcases = Array.new
				@@all_parameters.each do |parameters|
					testcases << Testcase.new(@@name, parameters, &block)
				end
				return testcases
			end
		end
	end

	def initialize(name, parameters, &code)
		@name = name
		@parameters = parameters
		@code = code
		@output = ""
		@result = UNKNOWN
	end

	# Executes the associated code, which will run within the context of caller,
	# not testcase.
	def execute
		if @parameters
			@code.call(@parameters)
		else
			@code.call
		end
	end

	def to_xml
		xml = REXML::Element.new("testcase")
		xml.add(REXML::Element.new("name").add_text(@name))
		xml.add(REXML::Element.new("parameters").add_text(@parameters.inspect))
		xml.add(REXML::Element.new("result").add_text(@result))
		xml.add(REXML::Element.new("output").add_text(REXML::CData.new(@output)))
		return xml
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