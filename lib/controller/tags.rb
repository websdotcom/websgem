module Webs
  module Controller
    module Tags
      def fwml tagname, options={}, &block
        s_options = ' ' + options.each_key.collect{|k| "#{k.to_s}=\"#{options[k]}\"" }.join(' ')  if options.size > 0
        
        return "<fw:#{tagname}#{s_options}/>" unless block

        content = capture(&block)
        output = ActiveSupport::SafeBuffer.new
        output.safe_concat("<fw:#{tagname}#{s_options}>")
        output << content
        output.safe_concat("</fw:#{tagname}>")
      end
      
      def webs_image_url img
        "http://#{Webs::ASSET_HOST}/images/#{img}"
      end
    end
  end
end