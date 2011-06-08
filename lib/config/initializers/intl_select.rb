# adds the fw:intl tag to options values
module ActionView
  module Helpers
    class FormBuilder
      def intl_select(method, choices, options = {}, html_options = {})
        @template.intl_select(@object_name, method, choices, options.merge(:object => @object), html_options)
      end
    end
    module FormOptionsHelper
      def intl_options_for_select(container, selected = nil)
        container = container.to_a if Hash === container

        options_for_select = container.inject([]) do |options, element|
          text, value = option_text_and_value(element)
          selected_attribute = ' selected="selected"' if option_value_selected?(value, selected)
          options << %(<option value="#{html_escape(value.to_s)}"#{selected_attribute}><fw:intl>#{html_escape(text.to_s)}</fw:intl></option>)
        end

        options_for_select.join("\n")
      end
      def intl_select(object, method, choices, options = {}, html_options = {})
        InstanceTag.new(object, method, self, nil, options.delete(:object)).to_intl_select_tag(choices, options, html_options)
      end
    end

    class InstanceTag #:nodoc:
      include FormOptionsHelper

      def to_intl_select_tag(choices, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        selected_value = options.has_key?(:selected) ? options[:selected] : value
        content_tag("select", add_options(intl_options_for_select(choices, selected_value), options, selected_value), html_options)
      end
    end
  end
end


