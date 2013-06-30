
class Log

	@@logfile = nil
	@@testcase = nil

	def self.testcase=(testcase)
		@@testcase = testcase
	end

	def self.logfile=(logfile)
		@@logfile = logfile
	end

	def self.info(message, tag)
		return if message == nil
		prefix = "[#{Time.now.strftime("%T.%L")}] "
		tag = tag != nil ? "[#{tag}] " : ""
		output = message.chomp.lines.to_a.map!{|line| line = prefix + tag + line}.join("") + "\n"
		File.open(@@logfile,'a') do |logfile|
			logfile.write(output)
		end if @@logfile
		@@testcase.output << output if @@testcase
		return message
	end

	def self.error(error)
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

def log(message)
	Log.info(message, nil)
end

def log_error(error)
	Log.error(error)
end