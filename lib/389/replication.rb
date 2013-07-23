

class DirectoryServer < LdapServer
    attr_reader :replication_manager_dn, :replication_manager_pw

    def add_replication_manager(dn="cn=replication manager,cn=config", password="Secret123")
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
        self.ldapmodify_r(input)
        if ! $?.success? then
            raise RuntimeError.new("Failed to add replication manager #{dn} \
                with password #{password}. Return code: #{$?.exitstatus}")
        end
    end

    def enable_changelog(dir="/var/lib/dirsrv/slapd-#{@name}/changelogdb")
        input = <<-EOF
            dn: cn=changelog5,cn=config
            objectclass: top
            objectclass: extensibleObject
            cn: changelog5
            nsslapd-changelogdir: #{dir}
            nsslapd-changelogmaxage: 10d
        EOF
        self.ldapadd_r(input)
        if ! $?.success? then
            raise RuntimeError.new("Failed to add changelog \'#{dir}\'. Return code: #{$?.exitstatus}")
        end
    end
end