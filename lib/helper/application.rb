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
    end
  end
end
