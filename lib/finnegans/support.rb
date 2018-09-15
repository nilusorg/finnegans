module Finnegans
  module Support
    class << self
      def snakecase(string)
        str = string.dup
        str.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        str.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        str.tr!('-', '_')
        str.gsub!(/\s/, '_')
        str.gsub!(/__+/, '_')
        str.downcase
      end
    end
  end
end
