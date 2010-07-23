module Webs
  module Controller
    
    def redirect_with_flash(message, options)
      flash[:notice] = message if message
      redirect_to options
    end
  
    def redirect_to_index(message=nil)
      redirect_with_flash message, :action => 'index'
    end
  end
end
