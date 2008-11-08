class ApplicationController < ActionController::Base
  include Slate::Navigation
  include Slate::Authentication

  # load helpers
  helper :all

  before_filter :capture_user!
  
  # Manually load the enclosing resources
  # and then capture the space - this is done
  # so we can properly set the Space.active class
  # variable
  before_filter :load_enclosing_resources
  before_filter :capture_space
  before_filter :authorize_space!

protected
  # Stub method for controllers that do not use RC
  def load_enclosing_resources
  end

  # Assigns active space based on instance variable
  # (from resources_controller)
  def capture_space
    Space.active = @space
  end
  
  def authorize_space!
    return true if Space.active.nil?
    return true if Space.active.permit?(User.active)
    flash[:error] = 'You are not authorized to view this space.'
    redirect_to dashboard_url and return false
  end
end