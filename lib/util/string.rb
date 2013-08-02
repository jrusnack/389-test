
class String
    def get_attr_value(attribute)
        values = self.lines.to_a.keep_if{|e| e =~ /^#{attribute}:.*/}.map{|line| line.gsub(/^#{attribute}: (.*)$/, '\1').strip}
        case
        # Multiple values
        when values.size > 1
            return values
        # Single value
        when values.size == 1
            return values[0]
        # No value of attribute found
        else
            return nil
        end
    end
end