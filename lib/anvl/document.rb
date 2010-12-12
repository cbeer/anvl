module ANVL
  class Document # < Hash
    def self.parse str
      anvl = self.new  str
      anvl
    end

    attr_reader :entries

    def initialize obj = nil
      @entries = Array.new

      case obj
        when Hash
          self.push obj

	when String
	  lines = obj.gsub(/\s?\n\s+/, ' ').split("\n")

	  lines.each_with_index do |str, i|
	    case str
	      when /^#/
                parse_comment str, i
              when /:/  
                parse_entry str, i
	      else  # something is wrong..
                nil
	    end  
	  end  

      end if obj

      add_entries_methods

      gc!
    end

    def to_s
      gc!
      @entries.map do |obj|
        case obj[:value]
          when Array
            obj[:value].map do |v|
              "#{obj[:display_label] || obj[:label]}: #{format_value(v)}"
            end.join "\n"
          else  
            "#{obj[:display_label] || obj[:label]}: #{format_value(obj[:value])}"
        end
      end.join "\n"
    end

    def to_h
      gc!
      h = {}

      @entries.map do |obj|
        h[(obj[:display_label] || obj[:label]).to_sym] ||= []
        h[(obj[:display_label] || obj[:label]).to_sym] << obj[:value] 
      end  

      h.each do |label, value|
        h[label] = value.first if value.length == 1
      end

      h
    end

    def [] display_label
      label = convert_label display_label
      v = @entries.select { |x| x[:label] == label }.map { |x| x[:value] }
      v &&= v.first if v.length == 1
      v
    end
    alias_method :fetch, :[]

    def []= display_label, value, append = false
      label = convert_label display_label
      value = [value] unless value.is_a? Array
      @entries.delete_if { |x| x[:label] == label } unless append
      value.each do |v|
        case v
          when Hash
            @entries << { :display_label => display_label, :label => label, :value => v }.merge(v)
          else
            @entries << { :display_label => display_label, :label => label, :value => v }
        end
      end
    end

    alias_method :store, :[]=

    def push hash
      hash.each do |label, value|
        self.store label, value, true
      end  
      gc!
      @entries
    end
    alias_method :'<<', :push

    private
    def parse_comment str, line=0

    end

    def parse_entry str, line=0
      label, value = str.split ":", 2
      self.store label, value.strip, true
    end

    def add_entries_methods
      @entries.reject { |x| self.respond_to? x[:label] }.each do |obj|
        (class << self; self; end).class_eval do
          define_method obj[:label] do |*args|
            @entries[obj[:label]]
	  end 
	end
      end
    end  

    def gc!
    end

    def format_value str = ''
      str = str.to_s
      str &&= format_initial_comma_to_recover_word_order str
      str &&= str.gsub(/\n/, "\n    ")
    end

    def format_initial_comma_to_recover_word_order str, sort_point = ','
      return str unless str[0, 1] == sort_point
      str.split(sort_point).reject { |x| x.empty? }.map(&:split).reverse.join " "
    end
    def convert_label label
      label.to_s.downcase.gsub(' ', '_')
    end
  end
end
