module Webs
  module Controller
    module WebsController
      def self.included(base)
        base.extend ClassMethods
      end
  
      module ClassMethods
        def webs_helpers
          helper Webs::Helper::Params
          helper Webs::Helper::Tags
          include Webs::Helper::Params
          include Webs::Helper::Tags
        end
      end

      def webs_query_string
        webs_params.collect{ |k,v| [k,v].join("=") }.join("&").to_s
      end          

      def webs_auth_string
        webs_params.collect{ |k,v| [k[7..-1],v].join("=") }.to_s
      end          

      # http://wiki.developers.webs.com/wiki/Verifying_Requests
      def webs_auth( secret )
        s = webs_auth_string
        Rails.logger.debug "****************** WEBS AUTH STRING=> #{s}"
        Digest::MD5.hexdigest(webs_auth_string + secret)
      end
    
      def require_valid_user
        render :text => "Access Denied: Webs::SECRET not defined." and return(false) unless defined?( Webs::SECRET )
        render :text => "Access Denied" and return(false) unless fw_sig == webs_auth( Webs::SECRET )
      end
    end
  end
end
