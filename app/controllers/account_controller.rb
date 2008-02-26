class AccountController < ApplicationController
  resources_controller_for :account, :class => User, :singleton => true do
    User.new(params[resource_name])
  end
  
  # don't try to find a user from the session or we'll
  # just end up in an infinite redirect loop
  skip_before_filter :capture_user!, :except => [:approve, :show]
  
public    
  def login
    if request.get?
      self.resource = capture_user || find_resource
      redirect_back_to self.resource.super_user? ? dashboard_url() : spaces_url() and return unless self.resource.new_record?
      render and return
    end
      
    self.resource = resource_service.login!(params[resource_name])
    session[:user_id] = self.resource.id
    redirect_back_to self.resource.super_user? ? dashboard_url() : spaces_url()
  rescue Slate::UserError => e
    self.resource = resource_service.new(:username => params[resource_name][:username])
    self.resource.errors.add_to_base e.message
    flash[:error] = e.message
  end
  
  # logout the current user
  def logout
    reset_session
    User.active = nil
    redirect_to login_url
  end
end