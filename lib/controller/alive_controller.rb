require 'socket'

class Webs::AliveController < ActionController::Base
  def index
    # Returns a 500 before ever getting here if cannot connect to database

    # avoid cache & 304, always return 200
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"

    # Only force down if calling from localhost
    render( :text=>'OK' ) and return unless Webs.cache

    server_down = fetch_server_down
    if request.local?
      if ['1', '-1'].include?( params['forceDown'] )
        server_down = '1'
        set_server_down( server_down )
      elsif params['forceDown'] == '0'
        Webs.cache.delete(cache_key)
        server_down = nil
      end
    end
    
    if server_down
      render :text=>"Server is going down!", :status=>503 
    else
      render :text=>'OK'
    end
  end

  private
  def cache_key
    this_host = Socket.gethostname
    "alive_#{this_host}"
  end
  
  def fetch_server_down
    if Webs.cache.respond_to?( 'read' )
      Webs.cache.read( cache_key )
    else
      Webs.cache[ cache_key ]
    end
  end
  
  def set_server_down server_down
    if Webs.cache.respond_to?( 'write' )
      Webs.cache.write(cache_key, server_down)
    else
      Webs.cache[ cache_key ] = server_down
    end
  end
end