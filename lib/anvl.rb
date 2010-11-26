module ANVL
  def self.parse str
    data = {}
    entries = []
    lines = str.split("\n")

    lines.each do |l|
      case l
        when /^\#/
	  # comment
	  next
        when /^\s/
          entries.last << l.gsub(/^\s+/, ' ') 
	else
          entries << l
      end
    end

    entries.each do |e|
      key, value = e.split ":", 2
      data[key.to_sym] ||= []
      data[key.to_sym] << value.strip
    end

    data.each do |key, value|
      data[key] = value.first if value.length == 1
    end

    data
  end

  def self.to_anvl h
    lines = []
    h.each do |key, value|
      if value.respond_to? :each
        value.each do |v|
          lines << "#{key}: #{v}"
        end
      else
        lines << "#{key}: #{value}" 
      end
    end
    lines.join "\n"
  end
end
