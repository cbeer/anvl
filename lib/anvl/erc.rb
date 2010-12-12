require 'anvl'
module ANVL
  class Erc < Document
    STORY_TO_OFFSET = { 'erc' => 0, 'about-erc' => 10, 'support-erc' => 20, 'meta-erc' => 30 }

    LABEL_TO_SYN = { 
      'who' => 'h1', 'what' => 'h2', 'when' => 'h3', 'where' => 'h4', 'how' => 'h5',
      'about-who' => 'h11', 'about-what' => 'h12', 'about-when' => 'h13', 'about-where' => 'h14', 'about-how' => 'h15',
      'support-who' => 'h21', 'support-what' => 'h22', 'support-when' => 'h23', 'support-where' => 'h24',
      'meta-who' => 'h31', 'meta-what' => 'h32', 'meta-when' => 'h33', 'meta-where' => 'h34'
    }

    SYN_TO_KERNEL = LABEL_TO_SYN.invert


    class Element < ANVL::Element
      def to_s
        str = super
        str &&= format_initial_comma_to_recover_word_order str
        str &&= decode_element_value_encoding str
        str
      end

      def =~ str
        bool = super

        label = convert_label str
        bool ||= (label =~ Regexp.new("\\(#{Regexp.escape(@label)}\\)"))
      end

      private
      def format_value_for_anvl
        super.sub(/^\s+([,;\|])/, '\1')
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

      def decode_element_value_encoding str
        h = { '%sp' => ' ', '%ex' => '!', '%dq' => '"', '%ns' => '#', '%do' => '$', '%pe' => '%', '%am' => '&', '%sq' => '\'', '%op' => '(', '%cp' => ')', '%as' => '*', '%pl' => '+', '%co' => ',', '%sl' => '/', '%cn' => ':', '%sc' => ';', '%lt' => '<', '%eq' => '=', '%gt' => '>', '%qu' => '?', '%at' => '@', '%ox' => '[', '%ls' => '\\', '%cx' => ']', '%vb' => '|', '%nu' => "\0", '%%' => '%' }
        s = str.dup
        h.each do |key, value|
         s.gsub! key, value
        end
        s
      end

      def convert_label label
        str = label.to_s.downcase.gsub(' ', '_')

        str = ANVL::Erc::LABEL_TO_SYN[str] if ANVL::Erc::LABEL_TO_SYN[str]

        str
      end

    end

    def []= display_label, value, append = false
      if value[0,1] != '|' and STORY_TO_OFFSET[display_label] and !value.strip.empty?
        process_abbr_form display_label, value 
      elsif value[0,1] != ';' and value =~ /;/
        value.split(';').each do |v|
          self.store display_label, v, true
        end
      else
        super
      end
    end
    alias_method :store, :[]=

    def complete?
      !(self.fetch(:h1).empty? or self.fetch(:h2).empty? or self.fetch(:h3).empty? or self.fetch(:h4).empty?) ||
      !(self.fetch(:h11).empty? or self.fetch(:h12).empty? or self.fetch(:h13).empty? or self.fetch(:h14).empty?)  ||
      !(self.fetch(:h21).empty? or self.fetch(:h22).empty? or self.fetch(:h23).empty? or self.fetch(:h24).empty?) ||
      !(self.fetch(:h31).empty? or self.fetch(:h32).empty? or self.fetch(:h33).empty? or self.fetch(:h34).empty?)
    end

    protected

    def element_class
      ANVL::Erc::Element
    end

    def process_abbr_form display_label, value
      offset = STORY_TO_OFFSET[display_label]
      elements = value.split('|')
      elements.each_with_index do |e, i|
        next if e.strip.empty?
        self.store "h#{offset + i + 1}", e.strip
      end
    end

  end
end
