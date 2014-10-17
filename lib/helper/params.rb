module Webs
  module Helper
    module Params
      FW_PARAMS = [:fw_sig, :fw_sig_site, :fw_sig_is_admin, :fw_sig_permission_level, :fw_sig_session_key, :fw_sig_tier, :fw_sig_permissions, :fw_sig_time, :fw_sig_api_key, 
       :fw_sig_url, :fw_sig_user, :fw_sig_width, :fw_sig_social, :fw_sig_premium, :fb_sig_network, :fw_sig_captcha_valid, :fw_sig_locale,
       :fw_sig_access_token, :fw_sig_partner ]
       
      FW_PARAMS.each do |fw_param|
         module_eval( "def #{fw_param.to_s}() params[:#{fw_param.to_s}] || request.headers['#{fw_param.to_s}'] end" )
      end
               
      # Some basic useful methods
      def webs_sitebuilder?
        fw_sig_is_admin == '1'
      end
      
      def webs_anyone?
        fw_sig_permission_level == Webs::PermissionLevel[:anyone].to_s
      end
      
      #TODO: is this same as anyone and can we ditch the -255??
      def webs_anonymous?
        fw_sig_permission_level == Webs::PermissionLevel[:none].to_s
      end
      
      def webs_limited?
        fw_sig_permission_level == Webs::PermissionLevel[:limited].to_s
      end
      
      def webs_member?
        fw_sig_permission_level == Webs::PermissionLevel[:member].to_s
      end
      
      def webs_moderator?
        fw_sig_permission_level == Webs::PermissionLevel[:moderator].to_s
      end
      
      def webs_admin?
        fw_sig_permission_level == Webs::PermissionLevel[:admin].to_s
      end
      
      def webs_owner?
        fw_sig_permission_level == Webs::PermissionLevel[:owner].to_s
      end
      
      #TODO: Also need to check the java??
      def webs_disabled?
        fw_sig_permission_level == Webs::PermissionLevel[:disabled].to_s
      end
      
      def webs_premium?
        fw_sig_premium == '1'
      end
      
      def webs_social?
        fw_sig_social == '1'
      end
      
      def webs_admin_owner_sitebuilder?
        webs_admin? || webs_owner? || webs_sitebuilder?
      end
      
      def webs_admin_owner?
        webs_admin? || webs_owner?
      end
      
      def webs_captcha_valid?
        fw_sig_captcha_valid == '1'
      end
      
      def webs_site_id
        fw_sig_site.to_i if !fw_sig_site.blank?
      end
      
			def webs_params
				headerParams = request.headers.select{ |k,v| k.downcase.starts_with?("http_fw_sig_") }.map{|k,v| [k[5..k.length].downcase, v] }
				bodyParams = params.select{ |k,v| k.starts_with?("fw_sig_") }
				headerParams.concat(bodyParams).sort
			end
      
      # The full url of the app.  Since in APP_NAME can be different in different environments this is currently
      # defined in a global var, usually in the respective env file, however APP_NAME should be moved to something
      # more elegant in the future.
      def webs_app_url
        app_name = webs_appenv_name
        raise "webs_app_url requires that the constant APP_NAME is defined.. for now..." if app_name.blank?
        "#{fw_sig_url}apps/#{app_name}"
      end
    end
  end
end
