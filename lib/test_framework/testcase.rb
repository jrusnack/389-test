
class Testcase

	class Builder
		def self.new(name)
			@@name = name
			@@parameters = Array.new
		end

		def self.add_parameters(values)
			@@parameters.concat([values])
		end

		def self.create_testcase(&block)
			testcase = Testcase.new(@@name, @@parameters, &block)
			@@name = nil
			@@parameters = nil
			return testcase
		end
	end

	def initialize(name, parameters, &block)
		@name = name
		@parameters = parameters
		@code = block
		@output = ""
	end

	def execute
		if @parameters.size != 0
			@parameters.each do |parm|
				puts "-- Running test #{@name} with parameters #{parm.inspect} --"
				@code.call(parm)
				puts "-- End of test #{@name} with parameters #{parm.inspect} --\n\n"
			end
		else
			puts "-- Running test #{@name} --"
			@code.call
			puts "-- End of test #{@name} --\n\n"
		end
	end

	def log(message)
		@output + "\n#{message}"
	end
end