
class Testcase

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
		result = REXML::Element.new("testcase")
		result.add(REXML::Element.new("name").text(@name))
		
	end

	private

	def log(message)
		@output + "\n#{message}"
	end
end