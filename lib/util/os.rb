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
module OS

    # Returns true iff OS is 64 bit
    def is_64?
        if `uname -r` =~ /x86_64/
            return true
        else
            return false
        end
    end

    # Returns machine hostname (first part of FQDN).
    def get_hostname
        return get_fqdn.partition('.')[0]
    end

    # Returns FQDN of host
    def get_fqdn
        return `hostname -f`
    end

    # Returns name of current user
    def get_current_user
        return `whoami`.chomp!
    end

    # Returns path to unique filename in /tmp
    def get_tmp_file
        tmp_file = `mktemp`.chomp!
        File.delete(tmp_file)
        return tmp_file
    end

    # Executes command in shell
    def sh(command)
        @log.info(`#{command} 2>&1`.chomp!, "SH")
    end

    # Returns random unused TCP port
    def get_free_port
        # Get upper and lower bound for ephemeral ports on this system
        ranges = File.open("/proc/sys/net/ipv4/ip_local_port_range",'r') {|file| file.read}
        # ranges contains "low high", split it on whitespace and convert both from string to integer
        low, high = ranges.split(/\s/).map {|e| e.to_i}
        10.times do
            random_port = rand(high - low) + low
            lsof_out = `lsof -iTCP:#{random_port}`
            return random_port if lsof_out.empty?
        end
        raise RuntimeError.new("Could not find any unused port.")
    end

    # Returns number of CPUs
    def number_of_cpus
        return `grep "^processor" /proc/cpuinfo | sort -u | wc -l`.to_i
    end

    # Returns true if the process with given PID is alive
    def is_process_alive?(pid)
        begin
          Process.getpgid(pid)
          true
        rescue Errno::ESRCH
          false
        end
    end
end