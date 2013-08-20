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
require '389/configuration'

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