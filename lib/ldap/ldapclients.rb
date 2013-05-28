

module Ldapclients

    attr_reader :mozldap, :openldap, :mozldap_path, :mozldap_ldapsearch, \
        :mozldap_ldapmodify, :mozldap_ldapadd, :openldap_ldapsearch, \
        :openldap_ldapmodify, :openldap_ldapadd

    #####################
    # SET SOME GLOBALS  #
    #####################
    
    # Discover paths to ldaptools
    @mozldap = false
    @openldap = false

    # If mozldap-tools are installed
    @mozldap_path = `whereis mozldap`.gsub("mozldap:","").chomp
    if @mozldap_path.length > 0
        @mozldap = true
        @mozldap_ldapsearch = @mozldap_path + "/ldapsearch"
        @mozldap_ldapmodify = @mozldap_path + "/ldapmodify"
        @mozldap_ldapadd    = @mozldap_path + "/ldapadd"
    end

    # If openldap clients are installed
    if `rpm -qa | grep openldap-clients`.length > 0 then
        @openldap = true
        @openldap_ldapsearch    = "/usr/bin/ldapsearch"
        @openldap_ldapmodify    = "/usr/bin/ldapmodify"
        @openldap_ldapadd       = "/usr/bin/ldapadd"
    end

    if ! @mozldap && ! @openldap then
        raise RuntimeError.new('No ldapclients found. Please make sure either openldap-clients or mozldap-tools are installed.')
    end

    #######################


    # Generic wrapper around ldapsearch - expects hash of options and version_to_use as arguments.
    # If version to use is not specified, it prefers mozldap. Options are given as a hash, so
    # they are independent of the tool used (mozldap or openldap one).
    #
    # === Parameters:
    # *options* ::            hash of options
    # *version_to_use*   ::   one of :default, :mozldap, :openldap. May be omitted.
    #
    # === Available options:
    # [:host]           LDAP server
    # [:port]           port on LDAP server
    # [:bind_dn]        bind DN
    # [:bind_pw]        password
    # [:base]           base dn for search
    # [:filter]         LDAP search filter
    # [:scope]          one of base, one, sub or children
    # [:attributes]     whitespace-separated list of attributes to retrieve
    #
    # === Examples
    #   Ldapclients::ldapsearch({:host => "localhost", :port => 389, :bind_dn => "cn=directory Manager", :bind_pw => "Secret123", :base => "dc=example,dc=com"}, :openldap )
    #   Ldapclients::ldapsearch({:host => "localhost", :port => 389, :bind_dn => "cn=directory Manager", :bind_pw => "Secret123", :base => "dc=example,dc=com"}, :mozldap )
    def self.ldapsearch(options={}, version_to_use = :default)

        if version_to_use == :default then
            version_to_use = @mozldap ? :mozldap : :openldap
        end

        # This will set command to the path to ldapsearch
        command = version_to_use == :mozldap ? @mozldap_ldapsearch.clone : @openldap_ldapsearch.clone

        # Build command string from options and input
        case version_to_use
        when :mozldap

            # Process options
            options.each do |key, value|
                case key
                when :host
                    command << " -h #{value}"
                when :port
                    command << " -p #{value}"
                when :bind_dn
                    command << " -D \"#{value}\""
                when :bind_pw
                    command << " -w \"#{value}\""
                when :base
                    command << " -b \"#{value}\""
                when :filter
                    command << " \"#{filter}\""
                when :scope
                    command << " -s \"#{value}\""
                when :attributes
                    command << " \"#{value}\""
                end
            end

            # If no filter was specified, enter default, otherwise syntax would be invalid for mozldap
            command << ' objectClass=* ' if !options.has_key?(:filter)

        when :openldap

            # Process options
            options.each do |key, value|
                case key
                when :host
                    command << " -h #{value}"
                when :port
                    command << " -p #{value}"
                when :bind_dn
                    command << " -D \"#{value}\""
                when :bind_pw
                    command << " -w \"#{value}\""
                when :base
                    command << " -b \"#{value}\""
                when :filter
                    command << " \"#{filter}\" "
                when :scope
                    command << " -s \"#{value}\""
                when :attributes
                    command << " \"#{value}\""
                end
            end

        else
            raise ArgumentError.new("Version_to_use argument expects either :mozldap or :openldap.")
        end

        return `#{command} 2>&1 `
    end


    # Generic wrapper around ldapmodify - expects hash of options, input string and version_to_use as arguments.
    # If version to use is not specified, it prefers mozldap. Options are given as a hash, so
    # they are independent of the tool used (mozldap or openldap one).
    #
    # === Parameters:
    # *options* ::          hash of options
    # *input* ::            string, may be omitted when :file option is specified
    # *version_to_use* ::   one of :default, :mozldap, :openldap. May be omitted.
    #
    # === Available options:
    # [:host]           LDAP server
    # [:port]           port on LDAP server
    # [:bind_dn]        bind DN
    # [:bind_pw]        password
    # [:file]           read operations from 'file'
    #
    # === Examples
    # Ldapclients::ldapmodify({:host => "localhost", :port => 389, :bind_dn => "cn=directory manager"}, "dn: cn=config\\n changetype: modify\\n replace: nsslapd-sizelimit\\n   nsslapd-sizelimit: 40000", :default)
    #
    def self.ldapmodify(options={}, input="", version_to_use = :default)
        if version_to_use == :default then
            version_to_use = @mozldap ? :mozldap : :openldap
        end

        # This will set command to the path to ldapmodify
        command = version_to_use == :mozldap ? @mozldap_ldapmodify.clone : @openldap_ldapmodify.clone

        # Build command string from options and input
        # Different for openldap and mozldap
        case version_to_use
        when :mozldap

          # Process options
            options.each do |key, value|
                case key
                when :host
                    command << " -h #{value}"
                when :port
                    command << " -p #{value}"
                when :bind_dn
                    command << " -D \"#{value}\""
                when :bind_pw
                    command << " -w \"#{value}\""
                when :file
                    command << " -f \"#{value}\""
                end
            end
        when :openldap

            # Process options
            options.each do |key, value|
                case key
                when :host
                    command << " -h #{value}"
                when :port
                    command << " -p #{value}"
                when :bind_dn
                    command << " -D \"#{value}\""
                when :bind_pw
                    command << " -w \"#{value}\""
                when :file
                    command << " -f \"#{value}\""
                end
            end

        else
            raise ArgumentError.new("Version_to_use argument expects either :mozldap or :openldap.")
        end

        # Don`t need input when file is specified
        if options.has_key?(:file) then
            return `#{command} 2>&1`
        else
            return `#{command} 2>&1 <<EOF\n#{input}\nEOF`
        end
    end

end