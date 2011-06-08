dir = Pathname(__FILE__).dirname.expand_path
ActionController::Base.append_view_path( "#{dir}/../../views" )
