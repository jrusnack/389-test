require 'ldap/ldapclients'

class LdapServer

    attr_reader :host, :port, :root_dn, :root_pw, :ldapclients_use

    def initialize(host, port, root_dn, root_pw)
        @host       = host
        @port       = port
        @root_dn    = root_dn
        @root_pw    = root_pw
    end

    # This is a generic ldapsearch method. Internally, it can use either mozldap or openldap version,
    # and therefore argument syntax has to be more generic. It should use mozldap version by default,
    # to be sure set version_to_use to either :mozldap, :openldap or :default
    #
    # Note that this is instance method, and so it performs ldapsearch against DS instance it is 
    # called on. You can specify :port, but :host will be overwritten. See implementation.
    def ldapsearch(options={}, version_to_use = :default)
        opt = options.clone                         # Clone, not to rewrite original params
        opt[:host] = @host                          # Set host, rewrite even when specified
        opt[:port] = @port if !opt.has_key?(:port)  # Set port, if not set already
        Ldapclients::ldapsearch(opt, version_to_use)
    end

    # This is a generic ldapmodify method. Internally, it can use either mozldap or openldap version,
    # and therefore argument syntax has to be more generic. It should use mozldap version by default,
    # to be sure set version_to_use to either :mozldap, :openldap or :default
    #
    # Note that this is instance method, and so it performs ldapmodify against DS instance it is 
    # called on. You can specify :port, but :host will be overwritten. See implementation.
    def ldapmodify(options={}, input="", version_to_use = :default)
        opt = options.clone                         # Clone, not to rewrite original params
        opt[:host] = @host                          # Set host, rewrite even when specified
        opt[:port] = @port if !opt.has_key?(:port)  # Set port, if not set already
        Ldapclients::ldapmodify(opt, input, version_to_use)
    end

end