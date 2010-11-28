module ANVL
  class Document # < Hash

    def self.parse str
      anvl = ANVL::Document.new  str
      anvl
    end

    attr_reader :entries

    def initialize obj = nil
      @entries = {}

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

      @entries.public_methods(false).each do |meth|
        (class << self; self; end).class_eval do
          define_method meth do |*args|
            @entries.send meth, *args
	  end unless self.respond_to? meth
	end
      end

      cleanup_entries
    end

    def to_s
      @entries.reject { |key, value| value.nil? }.map do |key, value|
        if value.is_a? Array
          value.map do |v|
            "#{key}: #{v}"
          end
        else
          "#{key}: #{value}" 
        end
      end.join "\n"
    end

    def [] key
      @entries[key] ||= []
      return @entries[key]
    end

    def []= key, value
      @entries[key] = value
    end

    def push hash
      hash.each do |key, value|
        @entries[key] ||= []
	if value.is_a? Array
	  value.each do |v|      
	    @entries[key] << v
	  end
        else
          @entries[key] << value
	end
      end
      @entries
    end
    alias_method :'<<', :push

    private

    def parse_comment str, line=0

    end

    def parse_entry str, line=0
      key, value = str.split ":", 2
      @entries[key.to_sym] ||= []
      @entries[key.to_sym] << value.strip
    end

    def cleanup_entries
      @entries.each do |key, value|
        @entries[key] = value.first if value.length == 1
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
