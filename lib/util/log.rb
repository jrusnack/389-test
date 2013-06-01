
class Log

	@@logfile = nil
	@@testcase = nil

	def self.testcase=(testcase)
		@@testcase = testcase
	end

	def self.logfile=(logfile)
		@@logfile = logfile
	end

	def self.info(message)
		prefix = "[#{Time.now.strftime("%T.%L")}] "
		output = message.lines.to_a.map!{|line| line = prefix + line}.join("")
		puts output
		File.open(@@logfile,'a') do |logfile|
			logfile.write(output)
		end if @@logfile
		@@testcase.output << output if @@testcase
	end

	def self.error(error)
		prefix = "[#{Time.now.strftime("%T.%L")}]"
		output = "#{prefix}[ERROR] #{error.message}\n#{error.backtrace.join("\n")}"
		puts output
		File.open(@@logfile,'a') do |logfile|
			logfile.write(output)
		end if @@logfile
		@@testcase.output << output if @@testcase
	end

end

def log(message)
	Log.info(message)
end

def log_error(error)
	Log.error(error)
end