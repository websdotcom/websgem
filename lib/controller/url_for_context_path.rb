module ActionDispatch
  module Routing
    module UrlFor
      alias_method :url_for_original, :url_for
 
      def url_for(options = nil)
        url = url_for_original(options)
       
        # Will remove a context path from a relative url. The issue happens when an 
        # webs platform application has a non-root context path.  By removing the context path from the 
        # url url_for and named paths will now work
        url = url[(Webs::PLATFORM_CONTEXT_PATH.length)..url.length-1] if defined?(Webs::PLATFORM_CONTEXT_PATH) && url.index( Webs::PLATFORM_CONTEXT_PATH )==0
 
        url
      end
    end
  end
end