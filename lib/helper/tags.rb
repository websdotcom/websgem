module Webs
  module Helper
    module Tags
      def fwml tagname, options={}, &block
#        Rails.logger.debug "****** fwml #{tagname} #{options.inspect}"
        if ['sanitize', 'wizzywig'].include?(tagname.to_s)
          self.send( "fw_#{tagname}", options, &block )
        else
          return inline_tag( tagname, options ) unless block
          render_tag_with_block tagname, options, false, &block
        end
      end
      
      private
      def html_options options
        ' ' + options.each_key.select{ |k| !options[k].blank? }.collect{|k| "#{k.to_s}=\"#{options[k]}\"" }.join(' ')  if options.any?
      end
      
      def render_tag_with_block tagname, options, cdata_wrapper=false, &block
#        Rails.logger.debug "****** render_tag_with_block #{tagname} #{options.inspect} cdata=#{cdata_wrapper}"
        content = capture(&block)
        output = ActiveSupport::SafeBuffer.new
        output.safe_concat("<fw:#{tagname}#{html_options(options)}>")
        output.safe_concat("<![CDATA[") if cdata_wrapper
        output << content  
        output.safe_concat("]]>") if cdata_wrapper
        output.safe_concat("</fw:#{tagname}>")
      end
      
      def inline_tag tagname, options
        "<fw:#{tagname}#{html_options(options)}/>"
      end
      
      def fw_sanitize options={}, &block
        cdata_wrapper = options.delete(:cdata) 
        cdata_wrapper = true if cdata_wrapper.nil?
        render_tag_with_block 'sanitize', options, cdata_wrapper, &block
      end
      
      # fw_wizzywig should never be called with a block the text is passed in via text
      def fw_wizzywig options={}
        wizzywig_text = options.delete( :wizzywig_text )
        "<fw:wizzywig #{html_options(options)}><![CDATA[#{wizzywig_text}]]></fw:wizzywig>"
      end
    end
  end
end

# No support for rails 2
# concat("<fw:#{tagname}#{s_options}>", block.binding)
# concat("<![CDATA[") if cdata_wrapper
# concat( content, block.binding)
# concat("]]>") if cdata_wrapper
# concat("</fw:#{tagname}>", block.binding)
