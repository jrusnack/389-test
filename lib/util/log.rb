
# Mix-in to classes that have defined class variable @log
# adds two methods: log and log_error
module LogMixin
	def log(message)
		@log.info(message, nil)
	end

	def log_error(error)
		@log.error(error)
	end
end

class Log
	attr_accessor :testcase

	@logfile = nil
	@testcase = nil

	def initialize(logfile)
		@logfile = logfile
	end

	def info(message, tag)
		return if message == nil
		prefix = "[#{Time.now.strftime("%T.%L")}] "
		tag = tag != nil ? "[#{tag}] " : ""
		# add prefix and tag in front of each line
		output = message.chomp.lines.to_a.map!{|line| line = prefix + tag + line}.join("") + "\n"
		# write to @logfile if it exists
		File.open(@logfile,'a') do |logfile|
			logfile.write(output)
		end if @logfile
		# write to the output of testcase is specified
		@testcase.output << output if @testcase
		return message
	end

	def error(error)
		prefix = "[#{Time.now.strftime("%T.%L")}]"
		if error.kind_of?(Failure) then
			info(error.message, "FAIL")
			info(error.backtrace[0], "FAIL")
		else
			info(error.message, "ERROR")
			info(error.backtrace[0], "ERROR")
		end
	end
end