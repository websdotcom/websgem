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

      def fwml tagname, options={}, &block
#        Rails.logger.debug "****** fwml #{tagname} #{options.inspect}"
        tagname = tagname.to_s unless tagname.nil?
        if ['sanitize', 'wizzywig'].include?(tagname)
          tag = self.send( "fw_#{tagname}", options, &block )
        else
          if block
            tag = render_tag_with_block tagname, options, false, &block
          else
            tag = inline_tag( tagname, options )
          end
        end

        html_safe_check( tag )
      end

      private
      def html_safe_check s
        return s if s.blank?
        s.respond_to?( 'html_safe' ) ? s.html_safe : s
      end

      def html_options options
        ' ' + options.each_key.select{ |k| !options[k].blank? }.collect{|k| "#{k.to_s}=\"#{options[k]}\"" }.join(' ')  if options.any?
      end

      def parse_fwml_options tagname, options
        s = ''
        intl_attrs = {}
        options.keys.each do |k|
          if k.to_s.ends_with?( '_intl' )
            option_name = k.to_s.gsub( /_intl$/, '' )
            intl_attrs[option_name] = options.delete( k )
          end
        end
        if intl_attrs
          s += intl_attrs.keys.collect{ |k| %[<fw:fwml-attribute name="#{k}"><fw:intl>#{intl_attrs[k]}</fw:intl></fw:fwml-attribute>] }.join( "\n" )
        end
        if tagname == 'intl' && ( tokens = options.delete( :tokens ) )
          s += tokens.keys.collect{ |k| %[<fw:intl-token name="#{k}">#{tokens[k]}</fw:intl-token>] }.join( "\n" )
        end
        s
      end
      
      def render_tag_with_block tagname, options, cdata_wrapper=false, &block
        content = capture(&block)

        # parse attributes to append before closing tag
        append_str = parse_fwml_options tagname, options 

        output = begin
          ActiveSupport::SafeBuffer.new
        rescue
          nil
        end

        if output
          # RAILS3
          output.safe_concat("<fw:#{tagname}#{html_options(options)}>")
          output.safe_concat("<![CDATA[") if cdata_wrapper
          output << content  
          output.safe_concat( append_str ) if !append_str.blank?
          output.safe_concat("]]>") if cdata_wrapper
          output.safe_concat("</fw:#{tagname}>")
        else
          # RAILS2
          concat("<fw:#{tagname}#{html_options(options)}>", block.binding)
          concat("<![CDATA[", block.binding) if cdata_wrapper
          concat( content, block.binding)
          concat( append_str, block.binding ) if !append_str.blank?
          concat("]]>", block.binding) if cdata_wrapper
          concat("</fw:#{tagname}>", block.binding)
        end
      end
      
      def inline_tag( tagname, options={} )
        value = options.delete( :value ) if ['intl'].include?(tagname)
        append_str = parse_fwml_options tagname, options 
        if !append_str.blank? || !value.blank?
          "<fw:#{tagname}#{html_options(options)}>#{value}#{append_str}</fw:#{tagname}>"
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
        html_safe_check "<fw:wizzywig #{html_options(options)}><![CDATA[#{wizzywig_text}]]></fw:wizzywig>"
      end
    end     
  end
end
