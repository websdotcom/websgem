module Webs
  module Controller
    module Params
      def fw_sig
        params[:fw_sig]
      end  
      
      def fw_sig_site
        params[:fw_sig_site]
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
   
      def fw_sig_width
        params[:fw_sig_width]
      end  
   
      def fb_sig_network
        params[:fb_sig_network]
      end
      
      # Some basic useful methods
      def webs_admin_mode?
        fw_sig_is_admin == '1'
      end
      
      def webs_permission
        case fw_sig_permissions
          when /admin/i
            ADMIN
          when /owner/i
            OWNER
          when /moderator/i
            MODERATORS
          when /contributor/i
            MEMBERS
          when /limited/i
            LIMITED
          else
            ANYONE
        end
      end
      
      # does fw_sig_permissions contain at least perm
      def webs_permission?( perm=ANYONE )
        webs_permission >= perm
      end

      def webs_admin?
        fw_sig_permissions && webs_permission == ADMIN
      end
      
      def webs_owner?
        fw_sig_permissions && webs_permission == MODERATORS
      end
      
      def webs_contributor?
        fw_sig_permissions && webs_permission == LIMITED
      end
      
      def webs_moderator?
        fw_sig_permissions && webs_permission == ANYONE
      end
      
      def webs_site_owner_or_admin?
        webs_admin? || webs_owner?
      end
      
      
      # The full url of the app.  Since in APP_NAME can be different in different environments this is currently
      # defined in a global var, usually in the respective env file, however APP_NAME should be moved to something
      # more elegant in the future.
      def webs_app_url
        raise "fw_app_url requires that the constant APP_NAME is defined.. for now..." if !defined?(APP_NAME)
        "#{fw_sig_url}apps/#{APP_NAME}"
      end
    end
  end
end