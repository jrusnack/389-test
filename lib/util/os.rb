
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