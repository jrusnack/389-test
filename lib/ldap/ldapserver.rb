require 'ldap/ldapclients'
require 'util/string'

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
    def ldapmodify(input="", options={}, version_to_use = :default)
        opt = options.clone                         # Clone, not to rewrite original params
        opt[:host] = @host                          # Set host, rewrite even when specified
        opt[:port] = @port if !opt.has_key?(:port)  # Set port, if not set already
        Ldapclients::ldapmodify(input, opt, version_to_use)
    end

    # This is a generic ldapadd method. Note that this is instance method,
    # and so it performs ldapadd against DS instance it is called on. You 
    # can specify :port, but :host will be overwritten. See implementation.
    def ldapadd(input="",options={}, version_to_use = :default)
        opt = options.clone                         # Clone, not to rewrite original params
        opt[:host] = @host                          # Set host, rewrite even when specified
        opt[:port] = @port if !opt.has_key?(:port)  # Set port, if not set already
        Ldapclients::ldapadd(input, opt, version_to_use)
    end

    # This is a generic ldapdelete method. Note that this is instance method,
    # and so it performs ldapdelete against DS instance it is called on. You 
    # can specify :port, but :host will be overwritten. See implementation.
    def ldapdelete(input="", options={}, version_to_use = :default)
        opt = options.clone                         # Clone, not to rewrite original params
        opt[:host] = @host                          # Set host, rewrite even when specified
        opt[:port] = @port if !opt.has_key?(:port)  # Set port, if not set already
        Ldapclients::ldapdelete(input, opt, version_to_use)
    end

    # Ldapsearch as root
    def ldapsearch_r(options={})
        opt = options.clone
        opt[:bind_dn] = @root_dn
        opt[:bind_pw] = @root_pw
        ldapsearch(opt)
    end

    # Ldapmodify as root
    def ldapmodify_r(input, options={})
        opt = options.clone
        opt[:bind_dn] = @root_dn
        opt[:bind_pw] = @root_pw
        ldapmodify(input, opt)
    end

    # Ldapadd as root
    def ldapadd_r(input, options={})
        opt = options.clone
        opt[:bind_dn] = @root_dn
        opt[:bind_pw] = @root_pw
        ldapadd(input, opt)
    end

    # Ldapdelete as root
    def ldapdelete_r(input, options={})
        opt = options.clone
        opt[:bind_dn] = @root_dn
        opt[:bind_pw] = @root_pw
        ldapdelete(input, opt)
    end

    # Bind as root and get value of attribute on entry
    # Returns single value or array of multiple values
    def get_attribute(attribute, entry)
        log "Getting attribute #{attribute} from entry #{entry}"
        return ldapsearch_r({:base => "#{entry}", :scope => 'base', :attributes => "#{attribute}",\
            :other => '-LLL'}).get_attr_value(attribute)
    end

end