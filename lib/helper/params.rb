module Webs
  module Helper
    module Params
      [:fw_sig, :fw_sig_site, :fw_sig_is_admin, :fw_sig_permission_level, :fw_sig_session_key, :fw_sig_tier, :fw_sig_permissions, :fw_sig_time, :fw_sig_api_key, 
       :fw_sig_url, :fw_sig, :fw_sig_user, :fw_sig_width, :fw_sig_social, :fb_sig_network].each do |fw_param|
         module_eval( "def #{fw_param.to_s}() params[:#{fw_param.to_s}] end" )
      end
               
      # Some basic useful methods
      def webs_admin_mode?
        fw_sig_is_admin == '1'
      end
      
      def webs_permission
        case fw_sig_permissions
          when /admin/i
            Permission::ADMIN
          when /owner/i
            Permission::OWNER
          when /moderator/i
            Permission::MODERATORS
          when /contributor/i
            Permission::MEMBERS
          when /limited/i
            Permission::LIMITED
          else
            Permission::ANYONE
        end
      end
      
      # does fw_sig_permissions contain at least perm
      def webs_permission?( perm=Permission::ANYONE )
        webs_permission >= perm
      end

      def webs_admin?
        fw_sig_permissions && webs_permission == Permission::ADMIN
      end
      
      def webs_owner?
        fw_sig_permissions && webs_permission == Permission::MODERATORS
      end
      
      def webs_contributor?
        fw_sig_permissions && webs_permission == Permission::LIMITED
      end
      
      def webs_moderator?
        fw_sig_permissions && webs_permission == Permission::ANYONE
      end
      
      def webs_social?
        fw_sig_social == '1'
      end
      
      def webs_site_owner_or_admin?
        webs_admin? || webs_owner?
      end
      
      def webs_params
        params.select{ |k,v| k.starts_with?("fw_sig_") }.sort
      end
      
      # The full url of the app.  Since in APP_NAME can be different in different environments this is currently
      # defined in a global var, usually in the respective env file, however APP_NAME should be moved to something
      # more elegant in the future.
      def webs_app_url
        app_name = APP_NAME if defined?(APP_NAME)
        app_name ||= Webs::APP_NAME if defined?(Webs::APP_NAME)
        raise "fw_app_url requires that the constant APP_NAME is defined.. for now..." if app_name.blank?
        "#{fw_sig_url}apps/#{app_name}"
      end
    end
  end
end