require 'anvl/document'
module ANVL
  def self.parse *args
    Document.parse *args
  end

  def self.to_anvl *args
    anvl = Document.parse *args
    anvl.to_s
  end
end
