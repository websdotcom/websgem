module Webs
  module Helper
    module Tags
      # Examples: 
      #
      # <%= fwml( :blah, :fw_attributes=>{:value=>fwml( :name, :uid=>'xxx') } ) do %>HELLO<% end %>
      # 
      # Renders:
      #
      # <fw:blah>HELLO<fw:fwml_attribute name="value"><fw:name uid="xxx"/></fw:fwml_attribute></fw:blah>

      def fwml tagname, options={}, &block
        attributes = options.delete( :fw_attributes )
#        Rails.logger.debug "****** fwml #{tagname} #{options.inspect}"
        if ['sanitize', 'wizzywig', 'intl'].include?(tagname.to_s)
          tag = self.send( "fw_#{tagname}", options, &block )
        else
          if block
            tag = render_tag_with_block tagname, options, false, &block
          else
            tag = inline_tag( tagname, attributes, options )
          end
        end

        if attributes 
          tagidx = tag.length - (tagname.length + 6)
          attribute_str = attributes.keys.collect{ |k| %[<fw:fwml_attribute name="#{k}">#{attributes[k]}</fw:fwml_attribute>] }.join( "\n" )
          tag = tag[0..tagidx-1] + attribute_str.html_safe + tag[tagidx..tag.length-1]
        end

        tag.html_safe 
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
      
      def inline_tag tagname, attributes = nil, options
        if attributes
          "<fw:#{tagname}#{html_options(options)}></fw:#{tagname}>"
        else
          "<fw:#{tagname}#{html_options(options)}/>"
        end
      end
      
      def fw_sanitize options={}, &block
        cdata_wrapper = options.delete(:cdata) 
        cdata_wrapper = true if cdata_wrapper.nil?
        render_tag_with_block 'sanitize', options, cdata_wrapper, &block
      end
      
      # fw_wizzywig should never be called with a block the text is passed in via text
      def fw_wizzywig options={}
        wizzywig_text = options.delete( :wizzywig_text )
        "<fw:wizzywig #{html_options(options)}><![CDATA[#{wizzywig_text}]]></fw:wizzywig>".html_safe
      end
      
      # can take an option: :tokens which is a hash for replacement and will add in the appropriate fw:intl-token tags 
      # ex: 
      #  <%= fwml :intl, :description=>"bogus", :tokens=>{ :tier=>"Tier 1", :image_limit=>"10", :upgrade_link=>"www.blah.com" } do %>
      #    As a {tier} member, each of your products can have a maximum of {image_limit}.
      #    Need more? Time to upgrade!
      #    {upgrade_link}
      #  <% end %>
      #
      #  Should Yield:
      #
      #  <fw:intl description="bogus">
      #    As a {tier} member, each of your products can have a maximum of {image_limit}.
      #    Need more? Time to upgrade!
      #    {upgrade_link}
      #    <fw:intl-token name="tier">Tier 1</fw:intl-token> 
      #    <fw:intl-token name="image_limit">10</fw:intl-token>
      #    <fw:intl-token name="upgrade_link">www.blah.com</fw:intl-token>
      #  </fw:intl>
      #
      # You should also be able to use it without a body, so this should work:
      # <% rubystring = 'hello world' %>
      # <%= fwml :intl, :value=rubystring %>
      # 
      # Should Yield
      #
      # <fw:intl>hello world</fw:intl>
      #
      def fw_intl options={}, &block

        value = options.delete( :value)
        tokens = options.delete( :tokens )
        if block
          tag = render_tag_with_block 'intl', options, false, &block
          
          idx = tag.length - 10
          token_str = tokens.keys.collect{ |k| %[<fw:intl-token name="#{k}">#{tokens[k]}</fw:intl-token>] }.join( "\n" )
          (tag[0..idx-1] + token_str.html_safe + tag[idx..tag.length-1]).html_safe
        else
          %[<fw:intl#{html_options(options)}>#{h value}</fw:intl>].html_safe
        end
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
