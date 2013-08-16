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

require 'util/global_mutex'

class DirectoryServer < LdapServer
    @@setup_instance_mutex = GlobalMutex.new

    def self.get_instance(log, params={})
        # Mutex to prevent having 2 DS with the same name
        @@setup_instance_mutex.acquire
        params[:port] = get_free_port if params[:port] == nil
        params[:name] = self.get_unused_instance_name if params[:name] == nil
        new_instance = self.new(log, params)
        new_instance.setup
        @@setup_instance_mutex.release
        return new_instance
    end

    # Returns version of installed DS
    def self.version
        return `rpm -qa | grep 389-ds-base-libs`.gsub(/389-ds-base-libs-(.*)/,'\1').strip
    end

    def self.get_unused_instance_name
        1000.times do |i|
            name = get_hostname + "#{i}"
            if ! File.exists? "/etc/dirsrv/slapd-#{name}"
                return name
            end
        end
        raise RuntimeError.new("Could not create new instance of Directory Server. No free instance name.")
    end

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
    end

    # Do not use this method, as it is not safe for parallel execution
    # Use DirectoryServer.get_instance method instead
    def setup
        # Create config for new DS instance
        config = <<-EOF
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

        # Remove spaces from the beginning and the end of lines
        config = config.lines.to_a.map{|line| line.strip}.join("\n")
        config_file = get_tmp_file
        File.open(config_file, "w+") {|file| file.write(config)}

        sh "sudo setup-ds.pl -s -f #{config_file}"

        if ! $?.success? then
            raise RuntimeError.new("Failed to create new instance. Return code: #{$?.exitstatus}")
        end
    end

    # Executes remove-ds.pl script on instance.
    def remove
        # Mutex to prevent running semanage multiple times at any moment
        @@setup_instance_mutex.acquire
        sh "sudo remove-ds.pl -i slapd-#{@name}"
        @@setup_instance_mutex.release
        if ! $?.success?
            raise RuntimeError.new("Error occurred while removing instance. Return code: #{$?.exitstatus}")
        end
    end

    def restart
        sh "sudo #{@iroot}/restart-slapd"
        if ! $?.success? then
            raise RuntimeError.new("Error occurred while restarting instance. Return code: #{$?.exitstatus}")
        end
    end

    def start
        # Don`t start if server is already running
        return if running?

        sh "sudo #{@iroot}/start-slapd"
        if ! $?.success? then
            raise RuntimeError.new("Error occurred while starting instance. Return code: #{$?.exitstatus}")
        end
    end

    def stop
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

    def add_user(dn)
        log "Adding user #{dn}"
        rdn = get_rdn(dn)
        input = <<-EOF
            dn: #{dn}
            objectClass: top
            objectClass: person
            objectClass: inetOrgPerson
            cn: #{rdn}
            sn: #{rdn}
            uid: #{rdn}
        EOF
        log self.ldapadd_r(input)

        if ! $?.success? then
            raise RuntimeError.new("Error occurred while adding new user. Return code: #{$?.exitstatus}")
        end
    end

    
end