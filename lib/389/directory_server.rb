

require 'util/os'
require 'ldap/ldapserver'

class DirectoryServer < LdapServer

    def initialize(params={})
        
        # Set general options
        @fqdn    = params[:fqdn]     || OS.get_fqdn
        @user    = params[:user]     || "nobody"
        @group   = params[:group]    || "nobody"

        # Set instance options
        @default_backend    = params[:backend]  || "userRoot"
        @default_suffix     = params[:suffix]   || "dc=example,dc=com"
        @name               = params[:name]     || OS.get_hostname
        port                = params[:port]     || 389
        root_dn             = params[:root_dn]  || "cn=directory manager"
        root_pw             = params[:root_pw]  || "Secret123"

        # Call superclass initialize method
        super("localhost", port, root_dn, root_pw)

        # Set root directory of instance, used later for starting/stopping the instance
        # $platform_64 bit global variable is set in Ldapclients module
        if OS.is_64? then
            @iroot = "/usr/lib64/dirsrv/slapd-#{@name}"
        else
            @iroot = "/usr/lib/dirsrv/slapd-#{@name}"
        end

        if File.exist?(@iroot) then
            # This variable keeps info whether DS instance has been set up or not
            @live = true
        else
            @live = false
        end
    end

    def setup
        # Create config for new DS instance
        # gsub will remove 8 spaces at the beginning of each line
        config = <<-EOF.gsub(/^ {8}/, '')
        [General]
        FullMachineName=#{@fqdn}
        SuiteSpotUserID=#{@user}
        SuiteSpotGroup=#{@group}

        [slapd]
        ServerPort=#{@port}
        ServerIdentifier=#{@name}
        Suffix=#{@default_suffix}
        RootDN=#{@root_dn}
        RootDNPwd=#{@root_pw}
        ds_bename=#{@default_backend}
        EOF

        config_file = OS.get_tmp_file
        log_file    = OS.get_tmp_file
        File.open(config_file, "w+") {|file| file.write(config)}

        `sudo setup-ds.pl -s -f #{config_file} &> #{log_file}`
        File.delete(config_file)

        if ! $?.success? then
            # Error occurred, find out what is the problem and raise Error with nice message
            log = File.open(log_file,"r").read

            case
            when log.index("command not found") != nil
                File.delete(log_file)
                raise RuntimeError.new("Cannot find commang setup-ds.pl. Make sure Directory Server packages are installed.")

            when log.index("Error: the server already exists") != nil
                File.delete(log_file)
                raise RuntimeError.new("Instance named #{@name} already exists. Remove it first or use different instance name.")

            when log.index("The port number \'#{@port}\' is not available for use.") != nil
                File.delete(log_file)
                raise RuntimeError.new("Port #{@port} is not available for use - may be invalid, already used or restricted.")
            
            else
                raise RuntimeError.new("Failed to create new instance due to unknown error. Return code: #{rc}. See #{log_file}")
            end
        else
            # Success
            @live = true
            return 0
        end
    end

    # Executes remove-ds.pl script on instance.
    def remove
        log_file = OS.get_tmp_file
        `sudo remove-ds.pl -i slapd-#{@name} &> #{log_file}`
        if ! $?.success?
            # Error occurred
            raise RuntimeError.new("Error occurred while removing instance. Return code: #{rc}. See #{log_file}")
        else
            File.delete(log_file)
            @live = false
            return 0
        end
    end

    def restart
        raise RuntimeError.new("Directory server has not been set up. Run \"setup\" method first.") if !@live
        log_file = OS.get_tmp_file
        if @port < 1024 then
            `sudo #{@iroot}/restart-slapd &> #{log_file}`
        else
            `#{@iroot}/restart-slapd &> #{log_file}`
        end
        if !running? then
            raise RuntimeError.new("Error occurred while restarting instance. Server is not running.")
        else
            File.delete(log_file)
            return 0
        end
    end

    def start
        raise RuntimeError.new("Directory server has not been set up. Run \"setup\" method first.") if !@live

        # Don`t start if server is already running
        return 0 if running?

        log_file = OS.get_tmp_file
        if @port < 1024 then
            `sudo #{@iroot}/start-slapd &> #{log_file}`
        else
             `#{@iroot}/start-slapd &> #{log_file}`
        end
        if ! $?.success? then
            raise RuntimeError.new("Error occurred while starting instance. Return code: ##{$?.exitstatus}. See #{log_file}")
        else
            File.delete(log_file)
            return 0
        end
    end

    def stop
        raise RuntimeError.new("Directory server has not been set up. Run \"setup\" method first.") if !@live

        # Don`t stop if server is already stopped
        return 0 if !running?

        log_file = OS.get_tmp_file
        `#{@iroot}/stop-slapd &> #{log_file}`
        if ! $?.success? then
            raise RuntimeError.new("Error occurred while stopping instance. Return code: #{$?.exitstatus}. See #{log_file}")
        else
            File.delete(log_file)
            return 0
        end
    end

    def running?
        if `service dirsrv status #{@name}`.index("is running") != nil then
            return true
        else
            return false
        end
    end

end