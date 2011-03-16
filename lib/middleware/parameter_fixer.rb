# OK this totally sucked.  Basically if you use a session store that sets the session  
# id via a request param key( :key=>'fw_sig_session_key' in the store config), request.params will get fired off during the middleware init
# which hoses the path_parameters.  So a quick and dirty is to just clear the request parameters out of 
# the middleware stack right after they get set by the mem_cache_store by using another Rack middleware.
# Here is the line that is causing problems: http://github.com/rails/rails/blob/v3.0.5/actionpack/lib/action_dispatch/middleware/session/abstract_store.rb#L207 
#
# NOTE: I tried to add this directly after the MemCacheStore as follows but to no avail
#
#Links::Application.config.middleware.insert_after "ActionDispatch::Session::MemCacheStore", "Webs::Middleware::ParameterFixer"
#
# What did work was adding it at the end, just be careful not to clobber another middleware that might set it, also it looks like this will change in a future release of rails:
#
#require "middleware/parameter_fixer.rb"
#Links::Application.config.middleware.use "Webs::Middleware::ParameterFixer"

module Webs 
  module Middleware
    class ParameterFixer
      def initialize(app)
        @app = app
      end

      def call(env)
        env["action_dispatch.request.parameters"] = nil 
        env["action_dispatch.request.path_parameters"] = nil 
        @app.call(env)
      end
    end
  end
end

