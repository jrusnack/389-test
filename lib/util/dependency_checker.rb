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

require 'open-uri'

module DependencyChecker
    BUGZILLA_FIXED_STATUS=['ON_QA', 'VERIFIED']

    def self.met_dependency?(dep)
        type, number = dep.split(':')
        case type
        when 'bug'
            return true if BUGZILLA_FIXED_STATUS.include?(self.get_bugzilla_status(number))
        else
            raise RuntimeError.new("Unkown dependency type #{type}. Input was #{dep}")
        end
        return false
    end

    # Returns status of bugzilla (NEW, ASSIGNED, MODIFIED, POST ...)
    def self.get_bugzilla_status(number)
        url = "https://bugzilla.redhat.com/show_bug.cgi?ctype=xml&id=#{number}"
        open(url) do |bugzilla_xml|
            xml = REXML::Document.new(bugzilla_xml)
            return xml.root.elements["bug/bug_status"].text
        end
    end
end