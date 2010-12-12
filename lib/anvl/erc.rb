require 'anvl'
module ANVL
  class Erc < Document
  class Element < ANVL::Element

    def to_s
      str = super
      str &&= format_initial_comma_to_recover_word_order str
      str
    end

    def to_anvl
      "#{@display_label || @label}:#{format_value_for_anvl}"
    end

    private
    def format_value_for_anvl
      @value.gsub(/\n/, "\n    ").gsub(/^(\w)/, ' \1')
    end

    def format_initial_comma_to_recover_word_order str, sort_point = ','
      return str unless str[0, 1] == sort_point
      arr = str.split(sort_point)
      arr.shift

      insig = nil
      if str[-1,1] == sort_point
        insig = arr.pop.strip
      end

      word = arr.pop
      arr = [arr.join ","]
      arr.unshift word
      arr.unshift insig

      arr.compact.map(&:strip).reject { |x|  x.empty?}.join " "
    end

    def convert_label label
      label.to_s.downcase.gsub(' ', '_')
    end

  end
    LABEL_TO_SYN = { 
      'who' => 'h1', 'what' => 'h2', 'when' => 'h3', 'where' => 'h4'
    }

    SYN_TO_KERNEL = LABEL_TO_SYN.invert

    INTERNATIONAL_LABELS = {
      /\(h1\)/ => 'h1', /\(h2\)/ => 'h2', /\(h3\)/ => 'h3', /\(h4\)/ => 'h4'
    }

    def [] display_label
      label = convert_label display_label
      z = super label
      z = super LABEL_TO_SYN[label] if z == []
      z = super SYN_TO_KERNEL[label] if z == []

      if z  == []
        label_to_syn(label).each do |k, v|
          z = super v if z == []
          z = super SYN_TO_KERNEL[v] if z == []
          break unless z == []
        end
      end

      z
    end

  #  def []= label, value
  #   super convert_label(label), {:display_label => label, :value => value}
  #  end

    protected
    def label_to_syn label
      INTERNATIONAL_LABELS.select { |k,v| k.is_a? Regexp }.select { |k,v| label.to_s =~ k }
    end

    def element_class
      ANVL::Erc::Element
    end

    def convert_label label
      label.to_s.downcase.gsub(' ', '_')
    end
  end
end
