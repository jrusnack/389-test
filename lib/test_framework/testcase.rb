
class Testcase

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

	def initialize(name, parameters, &block)
		@name = name
		@parameters = parameters
		@code = block
		@output = ""
		@result = UNKNOWN
	end

	def execute
		if @parameters
			puts "-- Running test #{@name} with parameters #{@parameters} --"
			@code.call(@parameters)
			puts "-- End of test #{@name} with parameters #{@parameters} --\n\n"
		else
			puts "-- Running test #{@name} --"
			@code.call
			puts "-- End of test #{@name} --\n\n"
		end
	end

	def to_xml
		xml = REXML::Element.new("testcase")
		xml.add(REXML::Element.new("name").add_text(@name))
		xml.add(REXML::Element.new("result").add_text(@result))
		xml.add(REXML::Element.new("output").add_text(@output))
		return xml
	end

	private

	def log(message)
		@output + "\n#{message}"
	end
end