class SessionsController < ApplicationController
  resources_controller_for :session, :class => User, :singleton => true do
    User.new(params[resource_name])
  end
  
  # don't try to find a user from the session or we'll
  # just end up in an infinite redirect loop
  skip_before_filter :capture_user!, :except => [:approve, :show]
  
protected
  # Called when a login is successful
  def successful_login
    save_login_cookie if remember_me?
    redirect_back_to dashboard_url
  end
  
  # Was the remember me checkbox checked?
  def remember_me?
    params[resource_name][:remember_me] == '1' rescue false
  end
  
public    
  # Show login form
  def new
    self.resource = capture_user || find_resource
    successful_login and return unless resource.new_record?
  end
  
  # Login user
  def create
    self.resource = resource_service.login!(params[resource_name])
    session[:user_id] = resource.id
    successful_login
  rescue Slate::UserError => e
    self.resource = resource_service.new(:username => params[resource_name][:username])
    self.resource.errors.add_to_base e.message
    flash[:error] = e.message
    render :action => 'new'
  end
  
  # DELETE /sessions
  # Logout the current user
  def destroy
    reset_session
    logout_current_user
    redirect_to login_url
  end
end