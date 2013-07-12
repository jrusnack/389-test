

module Ldapclients

    @openldap_ldapsearch    = `whereis ldapsearch`.gsub(/^ldapsearch:\s*([\/a-z]*)\s.*\n/, '\1')
    @openldap_ldapmodify    = `whereis ldapmodify`.gsub(/^ldapmodify:\s*([\/a-z]*)\s.*\n/, '\1')
    @openldap_ldapadd       = `whereis ldapadd`.gsub(/^ldapadd:\s*([\/a-z]*)\s.*\n/, '\1')

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
                    command << " \"#{filter}\" "
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
    def self.ldapmodify(options={}, input="", version_to_use = :default)

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
            return `#{command} 2>&1 <<EOF\n#{self. sanitize_input(input)}\nEOF`
        end
    end

    # Generic wrapper around ldapmodify - expects hash of options, input string and version_to_use as arguments.
    # Options are given as a hash, so they are independent of the tool used (mozldap or openldap one).
    def self.ldapadd(options={}, input="", version_to_use = :default)

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

    # Removes any whitespaces from the beginning and the end of each line of input
    def self.sanitize_input(input)
        return input.lines.to_a.map{|line| line.strip}.join("\n")
    end

end