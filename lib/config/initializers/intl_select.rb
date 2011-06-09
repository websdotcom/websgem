if Rails::VERSION::STRING[0].to_i < 3
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

else
# ======================================================================================
#                          RAILS 3
#

module ActionView
  module Helpers
    class FormBuilder
      def intl_select(method, choices, options = {}, html_options = {})
        @template.intl_select(@object_name, method, choices, objectify_options(options), @default_options.merge(html_options))
      end
    end
    module FormOptionsHelper
      def intl_options_for_select(container, selected = nil)
        return container if String === container

        container = container.to_a if Hash === container
        selected, disabled = extract_selected_and_disabled(selected).map do | r |
           Array.wrap(r).map { |item| item.to_s }
        end

        container.map do |element|
          html_attributes = option_html_attributes(element)
          text, value = option_text_and_value(element).map { |item| item.to_s }
          selected_attribute = ' selected="selected"' if option_value_selected?(value, selected)
          disabled_attribute = ' disabled="disabled"' if disabled && option_value_selected?(value, disabled)
          %(<option value="#{html_escape(value)}"#{selected_attribute}#{disabled_attribute}#{html_attributes}><fw:intl>#{html_escape(text)}</fw:intl></option>)
        end.join("\n").html_safe
      end
      def intl_select(object, method, choices, options = {}, html_options = {})
        InstanceTag.new(object, method, self, options.delete(:object)).to_intl_select_tag(choices, options, html_options)
      end
    end

    class InstanceTag #:nodoc:
      include FormOptionsHelper
      def to_intl_select_tag(choices, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        selected_value = options.has_key?(:selected) ? options[:selected] : value
        disabled_value = options.has_key?(:disabled) ? options[:disabled] : nil
        content_tag("select", add_options(intl_options_for_select(choices, :selected => selected_value, :disabled => disabled_value), options, selected_value), html_options)
      end
    end
  end
end


end
