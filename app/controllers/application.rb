# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # load helpers
  helper :navigation
  helper :toolbar

  before_filter :capture_user!
  
  # manually load the enclosing resources
  # and then capture the space
  before_filter :load_enclosing_resources
  before_filter :capture_space

protected
  # stub method for non-RC controllers
  def load_enclosing_resources
    # this is a stub method for controllers
    # that do not use RC
  end

  # before filter which assigns active user based on 
  # session.  If no user is found, a redirect to the 
  # login screen occurs
  def capture_user!
    unless capture_user
      flash[:notice] = "Please sign in first and then we'll take you back."
      session[:redirect_to] = url_for(:only_path => false)
      redirect_to login_url() and return false
    end
  end
  
  # assigns active user based on session
  def capture_user
    User.active = User.find_by_id(session[:user_id])
  end
  
  # assigns active space based on instance variable
  # (from resources_controller)
  def capture_space
    Space.active = @space
  end
  
  # redirects to the session variable :redirect_to
  # if set - otherwise, it performs a normal redirect
  # 
  # this method is useful for taking the user back to 
  # a page which requires authentication after they've
  # logged in
  def redirect_back_to(options = {}, *parameters_for_method_reference)
    options = session[:redirect_to] unless session[:redirect_to].nil?
    session[:redirect_to] = nil
    redirect_to options, *parameters_for_method_reference
  end
  
  # before filter which ensures that the active user 
  # is a super user
  def ensure_super_user!
    unless User.active && User.active.super_user?
      flash[:error] = "Super user is required to perform this task."
      session[:redirect_to] = url_for(:only_path => false)
      redirect_to login_url() and return false
    end
  end
end
