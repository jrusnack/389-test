
require 'ldap/ldapserver'
require 'ldap/ldap'
require 'util/os'
require 'util/log'

# Implementation of DirectoryServer class is split into several files.
# This allows to group methods related to certain functionality of DS (like
# SLL, replication, DNA, ...) in one file and prevents having one huge file with
# DS implementation.
require '389/basic_functionality'
require '389/replication'

class DirectoryServer < LdapServer
    # include LogMixin to add log() and log_error() methods to DirectoryServer
    # both use @log instance variable, so make sure it is defined for DS instance
    include LogMixin

    # include LDAP helper functions
    include Ldap

    # include OS will mix-in methods from OS module as instance methods
    # extend OS will mix-in methods from OS module as class methods
    # awful, but necessary if we want to use OS methods in both
    # instance (like self.get_instance) and class methods (like initialize)
    include OS
    extend OS
end