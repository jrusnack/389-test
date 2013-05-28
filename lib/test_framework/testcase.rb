
class Testcase
	def initialize(name, *parameters, &block)
		@name = name
		@parameters = parameters
		@block = block
		@output = ""
	end

	def execute
		puts "--Running test #{@name}--"
		if @parameters.size != 0
			@parameters.each do |parm|
				@block.call(parm)
			end
		else
			@block.call
		end
		puts "--End of test #{@name}--\n\n"
	end

	def log(message)
		@output + "\n#{message}"
	end
end