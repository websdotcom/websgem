class Webs::InfoController < ActionController::Base
  include Webs::Controller::WebsController
  webs_helpers

  def index
    render :partial=>'shared/webs_info'
  end
end