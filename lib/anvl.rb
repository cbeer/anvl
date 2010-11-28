module ANVL
  class Document # < Hash

    def self.parse str
      anvl = ANVL::Document.new  str
      anvl
    end

    attr_reader :entries

    def initialize obj = nil
      @entries = Hash.new { |h,k| h[k] = [] }

      case obj
        when Hash
          obj.each do |key, value|
            @entries[key.to_sym] = value
	  end
	when String
	  lines = obj.gsub(/\s?\n\s+/, ' ').split("\n")

	  lines.each_with_index do |str, i|
	    case str
	      when /^#/
                parse_comment str, i
	      else  
                parse_entry str, i
	    end  
	  end  

      end if obj

      add_entries_methods

      gc!
    end

    def to_s
      gc!
      @entries.map do |key, value|
        if value.is_a? Array
          value.map do |v|
            "#{key}: #{v}"
          end
        else
          "#{key}: #{value}" 
        end
      end.join "\n"
    end

    def to_h
      gc!
      @entries
    end

    def [] key
      return @entries[key]
    end

    def []= key, value
      value = [value] unless value.is_a? Array
      @entries[key] = value
    end

    def push hash
      hash.each do |key, value|
        @entries[key] = [@entries[key]] unless @entries[key].is_a? Array
	if value.is_a? Array
	  value.each do |v|      
	    @entries[key] << v
	  end
        else
          @entries[key] << value
	end
      end
      gc!
      @entries
    end
    alias_method :'<<', :push

    private

    def parse_comment str, line=0

    end

    def parse_entry str, line=0
      key, value = str.split ":", 2
      @entries[key.to_sym] << value.strip
    end

    def add_entries_methods
      @entries.public_methods(false).reject { |x| self.respond_to? x }.each do |meth|
        (class << self; self; end).class_eval do
          define_method meth do |*args|
            @entries.send meth, *args
	  end 
	end
      end
    end  

    def gc!
      @entries.delete_if { |key, value| value.nil? or (value.is_a? Array and value.empty?) }

      @entries.each do |key, value|
        @entries[key] = value.first if value.is_a? Array and value.length == 1
      end
    end
  end

  def self.parse *args
    Document.parse *args
  end

  def self.to_anvl *args
    anvl = Document.parse *args
    anvl.to_s
  end
end
