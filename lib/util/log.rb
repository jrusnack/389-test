# 389-test - testing framework for 389 Directory Server
#
# Copyright (C) 2013 Jan Rusnacko
#
# This file is part of 389-test.
#
# 389-test is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# 389-test is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with 389-test. If not, see <http://www.gnu.org/licenses/>.
#
# For alternative license options, contact the copyright holder.
#
# Jan Rusnacko <rusnackoj@gmail.com>

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
        message = message.to_s if ! message.kind_of?(String)
        prefix = "[#{Time.now.strftime("%T.%L")}] "
        tag = tag != nil ? "[#{tag}] " : ""
        # add prefix and tag in front of each line
        output = message.lines.to_a.map!{|line| line = prefix + tag + line}.join("")
        output = output.chomp + "\n"
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