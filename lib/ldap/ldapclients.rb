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

module Ldapclients

    @openldap_ldapsearch    = `whereis ldapsearch`.gsub(/^ldapsearch:\s*([\/a-z]*)\s.*\n/, '\1')
    @openldap_ldapmodify    = `whereis ldapmodify`.gsub(/^ldapmodify:\s*([\/a-z]*)\s.*\n/, '\1')
    @openldap_ldapadd       = `whereis ldapadd`.gsub(/^ldapadd:\s*([\/a-z]*)\s.*\n/, '\1')
    @openldap_ldapdelete    = `whereis ldapdelete`.gsub(/^ldapdelete:\s*([\/a-z]*)\s.*\n/, '\1')

    # Generic wrapper around ldapsearch - expects hash of options and version_to_use as arguments.
    # Options are given as a hash, so they are independent of the tool used (mozldap or openldap one).
    def self.ldapsearch(options={}, version_to_use = :default)

        # By default, we expect openldap clients
        if version_to_use == :default then
            version_to_use = :openldap
        end

        # Build command string from options and input
        case version_to_use
        when :openldap
            command = @openldap_ldapsearch.clone
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
                    command << " \"#{value}\" "
                when :scope
                    command << " -s \"#{value}\""
                when :other
                    command << " #{value}"
                when :attributes
                    command << " \"#{value}\""
                end
            end
        else
            raise ArgumentError.new("Version_to_use argument expects either :default or :openldap.")
        end

        return `#{command} 2>&1`
    end


    # Generic wrapper around ldapmodify - expects hash of options, input string and version_to_use as arguments.
    # Options are given as a hash, so they are independent of the tool used (mozldap or openldap one).
    def self.ldapmodify(input="", options={}, version_to_use = :default)

        # By default, we expect openldap clients
        if version_to_use == :default then
            version_to_use = :openldap
        end

        case version_to_use
        when :openldap
            command = @openldap_ldapmodify.clone
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
                when :other
                    command << " #{value}"
                when :file
                    command << " -f \"#{value}\""
                end
            end
        else
            raise ArgumentError.new("Version_to_use argument expects either :default or :openldap.")
        end

        # Don`t need input when file is specified
        if options.has_key?(:file) then
            return `#{command} 2>&1`
        else
            return `#{command} 2>&1 <<EOF\n#{self.sanitize_input(input)}\nEOF`
        end
    end

    # Generic wrapper around ldapdelete - expects hash of options, input string and version_to_use as arguments.
    # Options are given as a hash, so they are independent of the tool used (mozldap or openldap one).
    def self.ldapadd(input="", options={}, version_to_use = :default)

        # By default, we expect openldap clients
        if version_to_use == :default then
            version_to_use = :openldap
        end

        case version_to_use
        when :openldap
            command = @openldap_ldapadd.clone
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
                when :other
                    command << " #{value}"
                when :file
                    command << " -f \"#{value}\""
                end
            end
        else
            raise ArgumentError.new("Version_to_use argument expects either :default or :openldap.")
        end

        # Don`t need input when file is specified
        if options.has_key?(:file) then
            return `#{command} 2>&1`
        else
            return `#{command} 2>&1 <<EOF\n#{self.sanitize_input(input)}\nEOF`
        end
    end

    # Generic wrapper around ldapdelete - expects hash of options, input string and version_to_use as arguments.
    # Options are given as a hash, so they are independent of the tool used (mozldap or openldap one).
    def self.ldapdelete(input="", options={}, version_to_use = :default)

        # By default, we expect openldap clients
        if version_to_use == :default then
            version_to_use = :openldap
        end

        case version_to_use
        when :openldap
            command = @openldap_ldapdelete.clone
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
                when :other
                    command << " #{value}"
                end
            end
        else
            raise ArgumentError.new("Version_to_use argument expects either :default or :openldap.")
        end

        # Don`t need input when file is specified
        return `#{command} 2>&1 <<EOF\n#{self.sanitize_input(input)}\nEOF`
    end

    # Removes any whitespaces from the beginning and the end of each line of input
    def self.sanitize_input(input)
        return input.lines.to_a.map{|line| line.strip}.join("\n")
    end

end