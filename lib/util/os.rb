
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

    # Returns FQDN of host (also checks that FQDN is pingable).
    def get_fqdn
        fqdn = `hostname -f`
        # Try pinging hostname (packet count 1, timeout 2 sec)
        `ping -w 2 -c 1 #{fqdn}`
        if $? != 0 then 
            raise RuntimeError.new("Cannot ping own hostname. Make sure \'ping \`hostname\`\' works.")
        end
        return fqdn
    end

    # Returns name of current user
    def get_current_user
        return `whoami`.chomp!
    end

    # Returns path to unique filename in /tmp
    def get_tmp_file
        return `mktemp`.chomp!
    end

    # Executes command in shell
    def sh(command)
        @log.info(`#{command} 2>&1`.chomp!, "SH")
    end

end