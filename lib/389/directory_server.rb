

require 'ldap/ldapserver'
require 'util/os'
require 'util/log'

class DirectoryServer < LdapServer
    include OS
    include LogMixin

    def initialize(log, params={})
        @log = log
        
        # Set general options
        @fqdn    = params[:fqdn]     || get_fqdn
        @user    = params[:user]     || "nobody"
        @group   = params[:group]    || "nobody"

        # Set instance options
        @default_backend    = params[:backend]  || "userRoot"
        @default_suffix     = params[:suffix]   || "dc=example,dc=com"
        @name               = params[:name]     || get_hostname
        @host               = params[:host]     || "localhost"
        @port               = params[:port]     || 389
        @root_dn            = params[:root_dn]  || "cn=directory manager"
        @root_pw            = params[:root_pw]  || "Secret123"

        super(@host, @port, @root_dn, @root_pw)

        # Set root directory of instance, used later for starting/stopping the instance
        # $platform_64 bit global variable is set in Ldapclients module
        if is_64? then
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

        config_file = get_tmp_file
        File.open(config_file, "w+") {|file| file.write(config)}

        sh "sudo setup-ds.pl -s -f #{config_file}"
        
        if ! $?.success? then
            raise RuntimeError.new("Failed to create new instance. Return code: #{$?.exitstatus}")
        else
            @live = true
        end
    end

    # Executes remove-ds.pl script on instance.
    def remove
        sh "sudo remove-ds.pl -i slapd-#{@name}"
        if ! $?.success?
            raise RuntimeError.new("Error occurred while removing instance. Return code: #{$?.exitstatus}")
        else
            @live = false
        end
    end

    def restart
        raise RuntimeError.new("Directory server has not been set up. Run \"setup\" method first.") if !@live
        sh "sudo #{@iroot}/restart-slapd"
        if ! $?.success? then
            raise RuntimeError.new("Error occurred while restarting instance. Return code: #{$?.exitstatus}")
        end
    end

    def start
        raise RuntimeError.new("Directory server has not been set up. Run \"setup\" method first.") if !@live

        # Don`t start if server is already running
        return if running?

        sh "sudo #{@iroot}/start-slapd"
        if ! $?.success? then
            raise RuntimeError.new("Error occurred while starting instance. Return code: #{$?.exitstatus}")
        end
    end

    def stop
        raise RuntimeError.new("Directory server has not been set up. Run \"setup\" method first.") if !@live

        # Don`t stop if server is already stopped
        return if !running?

        sh "sudo #{@iroot}/stop-slapd"
        if ! $?.success? then
            raise RuntimeError.new("Error occurred while stopping instance. Return code: #{$?.exitstatus}")
        end
    end

    def running?
        if `sudo service dirsrv status #{@name}`.include?("is running.") then
            return true
        else
            return false
        end
    end

end