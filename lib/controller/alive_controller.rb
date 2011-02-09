class Webs::AliveController < ActionController::Base
  def index
    # Returns a 500 before ever getting here if cannot connect to database

    # avoid cache & 304, always return 200
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"

    # Only force down if calling from localhost
    render( :text=>'OK' ) and return if !request.local?
    if Webs.cache
      require 'socket'
      this_host = Socket.gethostname
      ENV.keys.sort.each{ |k| Rails.logger.debug "ENV #{k} = #{ENV[k]}"}
      request.headers.keys.sort.each{ |k| Rails.logger.debug "HEADER #{k} = #{request.headers[k]}"}
      key = "alive_#{this_host}"
      Rails.logger.debug "********** Checking Cache for Server Down: #{key}"
      server_down = Webs.cache.read(key)
      if server_down.nil? && ['1', '-1'].include?( params['forceDown'])
        server_down = '1'
        Webs.cache.write(key, server_down)
      elsif server_down && params['forceDown'] == '0'
        Webs.cache.delete(key)
        server_down = nil
      end
      Rails.logger.debug "********** Server Down?: #{server_down}"
      if server_down
        render :text=>"Server is going down!", :status=>503 
      else
        render :text=>'OK'
      end
    else
      if ['1', '-1'].include?( params['forceDown']) 
        render :text=>"Server is going down!", :status=>503 
      else
        render :text=>'OK'
      end
    end
  end
end