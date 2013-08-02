
module Ldap
    
    def get_rdn(dn)
        return dn.clone.gsub(/[a-zA-Z]*=([^,]*),.*/, '\1')
    end
end