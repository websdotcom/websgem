module Webs
  module Helper
    module Tags
      def fwml tagname, options={}, &block
        s_options = ' ' + options.each_key.collect{|k| "#{k.to_s}=\"#{options[k]}\"" }.join(' ')  if options.size > 0
        
        return "<fw:#{tagname}#{s_options}/>" unless block

        content = capture(&block)
        begin
          # Rails 3
          output = ActiveSupport::SafeBuffer.new
          output.safe_concat("<fw:#{tagname}#{s_options}>")
          output << content
          output.safe_concat("</fw:#{tagname}>")
        rescue
          concat("<fw:#{tagname}#{s_options}>", block.binding)
          concat( content, block.binding)
          concat("</fw:#{tagname}>", block.binding)
          
        end
      end
      
      def webs_image_url img
        "http://#{Webs::ASSET_HOST}/images/#{img}"
      end
    end
  end
end