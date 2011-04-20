module Webs
  module Helper
    module Application
      def cdata str="", &block
        return "<![CDATA[#{str}]]>" unless block
        
        content = capture(&block)
        begin
          # Rails 3
          output = ActiveSupport::SafeBuffer.new
          output.safe_concat("<![CDATA[")
          output << content
          output.safe_concat("]]>")
        rescue
          concat("<![CDATA[", block.binding)
          concat( content, block.binding)
          concat("]]>", block.binding)
        end
      end

      # shouldn't need this anymore for Rails 3, just use image_tag
      # def webs_image_url img
      #   "http://#{Webs::ASSET_HOST}/images/#{img}"
      # end
      
      def webs_info
        render :partial=>'shared/webs_info'
      end
      
      # return an array of value, name select options for the given levels
      # if names are present map the names by level key 
      def webs_permission_level_select_options levels=Webs::PERMISSION_LEVELS, names={}
        levels.collect do |lvl_key|
          lvl = PERMISSION_LEVEL[lvl_key]
          [ lvl[:value], names[lvl_key] || lvl[:name] ]
        end
      end

      def webs_page_settings options = {}
        options.keys.each do |k| 
          val = options[k]
          val = h(val)
          self.instance_variable_set("@#{k.to_s}".to_sym, val) 
        end
      end

      # break text every col
      def text_breaking_wrap(txt, col = 80)
        return nil if txt.blank?
        txt.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/, "\\1\\3 ")
      end
      
      # break text every col respecting tags
      def html_breaking_wrap(html, col=80)
        # Breakup the string by html tags
        tag_regex = /<\/?[^>]*>/
        if html && html =~ tag_regex
          # Breakup the string by html tags
          ss = StringScanner.new( html )
          a = []
          while ( ss.scan_until(tag_regex) )
            a << ss.pre_match if !ss.pre_match.blank?
            a << ss.matched 
            ss = StringScanner.new( ss.rest ) 
          end
          a << ss.rest if ss.rest?
          
          # For each non-tag break long words
          a.collect{ |s| s[0..0]=='<' ? s : text_breaking_wrap(s, col) }.join
        else
          text_breaking_wrap(html, col) 
        end
      end
  
      # Great for all browsers but opera, but doesn't work in fw:sanitize
      def breaking_wrap( s, max_width=5 )
        return s if s.blank? || s.length < max_width
        r = Regexp.new( ".{1,#{max_width}}" )
        s.scan(r).join("<wbr>")
      end
    end
  end
end
