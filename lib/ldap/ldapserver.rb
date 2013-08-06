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