module ANVL
  class Element 
    attr_reader :document, :label, :display_label, :value
    def initialize args
      @document = args[:document]
      @display_label = args[:display_label] || convert_label(args[:label])
      @label = convert_label(args[:label])
      @value = args[:value].to_s
    end

    def [] key
      self.send key.to_sym
    end

    def to_s
      str = @value
      str &&= str.gsub(/\s*\n\s+/, ' ')

      str
    end

    def to_anvl
      "#{@display_label || @label}:#{format_value_for_anvl}"
    end

    def <=> obj
      @value <=> obj
    end

    def == obj
      case obj
        when String
          return @value == obj if obj.is_a? String
        when Element  
          @label == obj.label && @value = obj.display_label
        else
          false
      end
    end

    def =~ str
      str = str.to_s
      str == @label or str == @display_label or convert_label(str) == @label
    end

    def push value
      @document.store @display_label,  value, true
    end
    alias_method :'<<', :push

    private
    def format_value_for_anvl
      " " + @value.gsub(/\n/, "\n    ")
    end

    def convert_label label
      label
    end

  end
end
