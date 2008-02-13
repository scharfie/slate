class DashboardController < ApplicationController
  resources_controller_for :dashboard, :singleton => true, :only => :show

protected
  # shows the user dashboard when accessed via 
  # /dashboard by a normal user
  def user_dashboard
    render :action => 'user'
  end
  
  # show the admin dashboard when accessed via
  # /dashboard by a super user
  def admin_dashboard
    render :action => 'admin'
  end

  # shows the space dashboard when accessed via
  # /spaces/:space_id/dashboard
  def space_dashboard
    render :action => 'space'
  end
  
public
  # renders appropriate dashboard based on user type
  # and access mode (direct or via /spaces)
  def show
    space_dashboard and return if enclosing_resource
    admin_dashboard and return if User.active.super_user?
    user_dashboard  and return
  end
  
  # make sure that any pre-defined routes get kicked
  # back to /show
  %w(new destroy create edit).each do |action|
    define_method action do
      redirect_to :action => 'show'
    end  
  end
end