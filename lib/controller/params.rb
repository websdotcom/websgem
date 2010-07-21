module Webs
  module Controller
    module Params
      def fw_sig
        params[:fw_sig]
      end  
      
      def fw_sig_is_admin
        params[:fw_sig_is_admin]
      end  

      def fw_sig_permission_level
        params[:fw_sig_permission_level]
      end  
      
      def fw_sig_session_key
        params[:fw_sig_session_key]
      end  
      
      def fw_sig_tier
        params[:fw_sig_tier]
      end  
      
      def fw_sig_permissions
        params[:fw_sig_permissions]
      end  
      
      def fw_sig_time
        params[:fw_sig_time]
      end  
   
      def fw_sig_api_key
        params[:fw_sig_api_key]
      end  
   
      def fw_sig_url
        params[:fw_sig_url]
      end  
   
      def fw_sig
        params[:fw_sig]
      end  
   
      def fb_sig_network
        params[:fb_sig_network]
      end
      
      # Some basic useful methods
      
      # The full url of the app.  Since in APP_NAME can be different in different environments this is currently
      # defined in a global var, usually in the respective env file, however APP_NAME should be moved to something
      # more elegant in the future.
      def fw_app_url
        raise "fw_app_url requires that the constant APP_NAME is defined.. for now..." if !defined?(APP_NAME)
        "#{fw_sig_url}apps/#{APP_NAME}"
      end
    end
  end
end