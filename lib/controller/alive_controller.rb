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

    this_host = Socket.gethostname
    key = "alive_#{this_host}"

    server_down = Webs.cache.read(key)
    if request.local?
      if ['1', '-1'].include?( params['forceDown'] )
        server_down = '1'
        Webs.cache.write(key, server_down)
      elsif params['forceDown'] == '0'
        Webs.cache.delete(key)
        server_down = nil
      end
    end
    
    if server_down
      render :text=>"Server is going down!", :status=>503 
    else
      render :text=>'OK'
    end
  end
end