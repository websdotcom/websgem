module Webs
  mattr_accessor :app_name
  
  module Controller
    module WebsController
      def self.included(base)
        base.extend ClassMethods
      end
  
      module ClassMethods
        mattr_accessor :disable_cache
        def webs_helpers
          helper Webs::Helper::Application
          helper Webs::Helper::Params
          helper Webs::Helper::Tags
          helper Webs::Cache unless disable_cache
          include Webs::Helper::Params
          include Webs::Helper::Tags
          include Webs::Cache unless disable_cache
          helper_method :webs_site
          helper_method :webs_app_name
          helper_method :webs_permapath
          helper_method :webs_appenv_name
        end
      end
      
      def webs_app_name
        Webs::APP_NAME || APP_NAME
      end

      def webs_appenv_name
        unless defined?(Webs::USE_ENV_IN_APPNAME) && Webs::USE_ENV_IN_APPNAME == false
          suffix = Rails.env
          suffix = {'development' => 'dev', 'beta'=>'qa' }[suffix] || suffix
          suffix = nil if suffix == 'production'
          
          "#{webs_app_name}#{'.'+suffix if !suffix.nil?}"
        else
          webs_app_name
        end
      end

      def webs_permapath
        @permapath
      end

      def webs_query_string
        webs_params.collect{ |k,v| [k,v].join("=") }.join("&")
      end          

      def webs_auth_string
        webs_params.collect{ |k,v| [k[7..-1],v].join("=") }.join
      end          

      # http://wiki.developers.webs.com/wiki/Verifying_Requests
      def webs_auth( secret )
        s = webs_auth_string
        Digest::MD5.hexdigest(webs_auth_string + secret)
      end

      # Examples:
      # webs_redirect acontroller_path( @model_object )
      # webs_redirect acontroller_path( @model_object ), :partials=>[partial1, partial2]
      # webs_redirect :controller=>:acontroller, :flash=>'a message'
      def webs_redirect(*args)
        if args && args[0] && args[0].class.to_s =~ /String/
          url = args[0]
          options = args[1]
        else
          options = args[0]
        end  
    
        options ||= {}
        if options.class.to_s =~ /Hash/
          partials = options.delete(:partials)
        end
        
        message = options.delete(:flash)
        flash[:notice] = message if !message.blank?
        
        url = url_for( options.merge(:only_path=>true) ) if url.blank?
    
        render_text = %[<fw:redirect url="#{url}">Redirecting, please wait...]
        if partials && partials.any?
          partials.each do |p| 
            p = render_to_string( :partial=>p ) 
            render_text += p 
          end
        end
        render_text += %[</fw:redirect>]
        Rails.logger.debug render_text
        render :text => render_text
      end

      # FILTERS
      def set_page_title
        @title = @page_title = Webs::app_title
      end
      
      def set_webs_permapath pp=nil
        @permapath = pp 
        if @permapath.nil?
          @permapath = request.path
          if !@permapath.blank? && defined?(Webs::PLATFORM_CONTEXT_PATH) && @permapath.index( Webs::PLATFORM_CONTEXT_PATH )==0
            @permapath = @permapath[(Webs::PLATFORM_CONTEXT_PATH.length)..@permapath.length-1] 
          end
        end
        @permapath ||= "/"
        @permapath
      end

      def validate_webs_session
        render( :text => "Access Denied: Webs::SECRET not defined.", :status=>403 ) and return(false) unless defined?( Webs::SECRET )
        render( :text => "Access Denied", :status=>403 ) and return(false) unless fw_sig == webs_auth( Webs::SECRET )
      end
      
      def require_webs_user
        render( :text => "<fw:require-login />" ) unless !fw_sig_user.blank? && fw_sig_user.to_i > 0
      end
      
      def require_webs_admin
        render( :text => "You are not authorized.", :status=>403 ) unless webs_admin_owner?
      end
      
      def require_sitebuilder
        render( :text => "You are not an admin.", :status=>403 ) unless webs_sitebuilder?
      end
      
      def webs_site
        @webs_site
      end
      
      # options include primary_key_col
      def load_site_model modelname, options={}
        model = modelname.constantize
        pk = options.delete(:primary_key_col)
        if pk
          @webs_site = model.find( :first, :conditions=>{ pk=>webs_site_id } )
        else
          @webs_site = model.find( webs_site_id )
        end
          
        rescue
          nil
      end
      
      def log_fw_params
        Rails.logger.debug "FW_PARAMS={"
        Rails.logger.debug params.select{ |k,v| k.starts_with?("fw_sig_") }.sort.collect { |k,v| "  :#{k}=>'#{v}'" }.join(",\n")
        Rails.logger.debug "}"
      end
      
      # Usefull for debugging, set FW_PARAMS in development.rb and you can see the raw html in a browser
      def set_fw_params
        if defined?( FW_PARAMS )
          params.merge!( FW_PARAMS ) 
          Rails.logger.debug "************ set_fw_params PARAMS=#{params.inspect}"
        end
      end
      
      # NOTE: bots & perl scripts are getting bad format in the request headers
      # generally in the form: :formats=>["charset=iso-8859-1"] 
      # Just force those to html
      # ex: https://freewebs.hoptoadapp.com/errors/4334788 
      # ex mime type inspection: #<Mime::Type:0x765a7159 @synonyms=[], @string="charset=iso-8859-1", @symbol=nil> 
      def fix_request_format
        request.format = :html if request.format.blank? || ( request.format.to_s =~ /^charset/i || request.format.to_s =~ /^url_encoded_form/i )
      end

      def fix_encoding 
        fix_encoding_for_hash params
      end

      def fix_encoding_for_hash h_params
        return if h_params.nil?
        h_params.each_pair do |k,v|
          if v.is_a?(String)
            h_params[k] = to_iso8859( v )
          elsif v.is_a?(Hash)
            fix_encoding_for_hash v
          elsif v.is_a?(Array)
            fix_encoding_for_array v
          end
        end
      end


      def fix_encoding_for_array a_params
        return if a_params.nil?
        a_params.each_with_index do |v, idx|
          if v.is_a?(String)
            a_params[idx] = to_iso8859( v )
          elsif v.is_a?(Hash)
            fix_encoding_for_hash v
          elsif v.is_a?(Array)
            fix_encoding_for_array v
          end
        end
      end

    end
  end
end
