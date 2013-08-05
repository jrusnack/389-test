
module Ldap
    
    def get_rdn(dn)
        return dn.clone.gsub(/[a-zA-Z]*=([^,]*),.*/, '\1')
    end

    def escape_dn(dn)
        escapes = {'=' => '\=', ' ' => '', '"' => '\"', '+' => '\+', ',' => '\,', ';' => '\;', '<' => '\,', '>' => '\>'}
        return dn.gsub(/[ ="+,;<>]/, escapes)
    end
end