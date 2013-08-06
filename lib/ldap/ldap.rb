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

module Ldap
    
    def get_rdn(dn)
        return dn.clone.gsub(/[a-zA-Z]*=([^,]*),.*/, '\1')
    end

    def escape_dn(dn)
        escapes = {'=' => '\=', ' ' => '', '"' => '\"', '+' => '\+', ',' => '\,', ';' => '\;', '<' => '\,', '>' => '\>'}
        return dn.gsub(/[ ="+,;<>]/, escapes)
    end
end