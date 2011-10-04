require 'iconv'

module Webs
  module Helper
    module Encoding
      def to_utf8( s )
        Iconv.conv("utf-8", "ISO-8859-1", s)    
      rescue
        s
      end
      def to_iso8859( s )
        Iconv.conv("ISO-8859-1", "utf-8",  s )    
      rescue
        s
      end
    end
  end
end
