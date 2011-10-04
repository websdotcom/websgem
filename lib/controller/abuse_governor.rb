module Webs
  module Controller
    module AbuseGovernor
      def webs_register_post(key_prefix, max_per_time_window)
        key = "#{key_prefix}-#{request.env["HTTP_FW_IP_ADDRESS"]}"
        list = cache_get(key) || []
        list << Time.now
        list = list[(list.size - max_per_time_window)..max_per_time_window] if list.size > max_per_time_window
        cache_set(key, list)
      end

      def webs_require_captcha?(key_prefix, max_per_time_window)
        key = "#{key_prefix}-#{request.env["HTTP_FW_IP_ADDRESS"]}"
        list = cache_get(key)

        return false if list.nil? || list.size < max_per_time_window

        list[0].to_i > (Time.now-1.hour).to_i
      end
    end
  end
end

