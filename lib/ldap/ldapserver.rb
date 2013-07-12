require 'ldap/ldapclients'

class LdapServer

    attr_reader :host, :port, :root_dn, :root_pw, :ldapclients_use

    def initialize(host, port, root_dn, root_pw)
        @host       = host
        @port       = port
        @root_dn    = root_dn
        @root_pw    = root_pw
    end

    # This is a generic ldapsearch method. Note that this is instance method,
    # and so it performs ldapsearch against DS instance it is called on. You 
    # can specify :port, but :host will be overwritten. See implementation.
    def ldapsearch(options={}, version_to_use = :default)
        opt = options.clone                         # Clone, not to rewrite original params
        opt[:host] = @host                          # Set host, rewrite even when specified
        opt[:port] = @port if !opt.has_key?(:port)  # Set port, if not set already
        Ldapclients::ldapsearch(opt, version_to_use)
    end

    # This is a generic ldapmodify method. Note that this is instance method,
    # and so it performs ldapmodify against DS instance it is called on. You 
    # can specify :port, but :host will be overwritten. See implementation.
    def ldapmodify(options={}, input="", version_to_use = :default)
        opt = options.clone                         # Clone, not to rewrite original params
        opt[:host] = @host                          # Set host, rewrite even when specified
        opt[:port] = @port if !opt.has_key?(:port)  # Set port, if not set already
        Ldapclients::ldapmodify(opt, input, version_to_use)
    end

    # This is a generic ldapadd method. Note that this is instance method,
    # and so it performs ldapadd against DS instance it is called on. You 
    # can specify :port, but :host will be overwritten. See implementation.
    def ldapadd(options={}, input="", version_to_use = :default)
        opt = options.clone                         # Clone, not to rewrite original params
        opt[:host] = @host                          # Set host, rewrite even when specified
        opt[:port] = @port if !opt.has_key?(:port)  # Set port, if not set already
        Ldapclients::ldapadd(opt, input, version_to_use)
    end

    # Ldapsearch as root
    def ldapsearch_r(options={})
        opt = options.clone
        opt[:bind_dn] = @root_dn
        opt[:bind_pw] = @root_pw
        ldapsearch(opt)
    end

    # Ldapmodify as root
    def ldapmodify_r(options={}, input)
        opt = options.clone
        opt[:bind_dn] = @root_dn
        opt[:bind_pw] = @root_pw
        ldapmodify(opt, input)
    end

    # Ldapadd as root
    def ldapadd_r(options={}, input)
        opt = options.clone
        opt[:bind_dn] = @root_dn
        opt[:bind_pw] = @root_pw
        ldapadd(opt, input)
    end

end