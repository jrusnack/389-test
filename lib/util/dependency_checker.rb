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