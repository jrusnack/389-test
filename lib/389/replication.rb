

class DirectoryServer < LdapServer
    attr_reader :replication_manager_dn, :replication_manager_pw

    def add_replication_manager(dn="cn=replication manager,cn=config", password="Secret123")
        log "Adding replication manager #{dn}"
        @replication_manager_dn = dn
        @replication_manager_pw = password
        input = <<-EOF
            dn: #{dn}
            objectClass: inetorgperson
            objectClass: person
            objectClass: top
            cn: replication manager
            sn: RM
            userPassword: #{password}
            passwordExpirationTime: 20380119031407Z
            nsIdleTimeout: 0
        EOF
        log self.ldapadd_r(input)
        if ! $?.success? then
            raise RuntimeError.new("Failed to add replication manager \"#{dn}\" with password #{password}. Return code: #{$?.exitstatus}")
        end
    end

    def enable_changelog(dir="/var/lib/dirsrv/slapd-#{@name}/changelogdb")
        log "Enabling changelog: #{dir}"
        log self.ldapadd_r <<-EOF
            dn: cn=changelog5,cn=config
            objectclass: top
            objectclass: extensibleObject
            cn: changelog5
            nsslapd-changelogdir: #{dir}
            nsslapd-changelogmaxage: 10d
        EOF
        if ! $?.success? then
            raise RuntimeError.new("Failed to add changelog \'#{dir}\'. Return code: #{$?.exitstatus}")
        end
    end

    def enable_supplier(suffix, id)
        log "Enabling supplier: suffix #{suffix} with id #{id}"
        enable_replica(suffix, id, 3, 1)
        if ! $?.success? then
            raise RuntimeError.new("Failed to enable supplier: suffix #{suffix} with id #{id}. Return code: #{$?.exitstatus}")
        end
    end

    def enable_consumer(suffix, id)
        log "Enabling consumer: suffix #{suffix} with id #{id}"
        enable_replica(suffix, id, 2, 0)
        if ! $?.success? then
            raise RuntimeError.new("Failed to enable consumer: suffix #{suffix} with id #{id}. Return code: #{$?.exitstatus}")
        end
    end

    def enable_hub(suffix, id)
        log "Enabling hub: suffix #{suffix} with id #{id}"
        enable_replica(suffix, id, 2, 1)
        if ! $?.success? then
            raise RuntimeError.new("Failed to enable hub: suffix #{suffix} with id #{id}. Return code: #{$?.exitstatus}")
        end
    end

    private

    def enable_replica(suffix, id, type, flags)
        log self.ldapadd_r <<-EOF
            dn: cn=replica,cn="#{suffix}",cn=mapping tree,cn=config
            changetype: add
            objectclass: top
            objectclass: nsds5replica
            objectclass: extensibleObject
            cn: replica
            nsds5replicaroot: #{suffix}
            nsds5replicaid: #{id}
            nsds5replicatype: #{type}
            nsds5flags: #{flags}
            nsds5ReplicaPurgeDelay: 604800
            nsds5ReplicaBindDN: #{@replication_manager_dn}
        EOF
    end
end