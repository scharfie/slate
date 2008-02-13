class AccountController < ApplicationController
  resources_controller_for :account, :class => User, :singleton => true do
    User.new(params[resource_name])
  end
  
  # don't try to find a user from the session or we'll
  # just end up in an infinite redirect loop
  skip_before_filter :capture_user!, :except => [:approve, :show]
  before_filter :ensure_super_user!, :only => :approve
  
protected
  # sends a verification email to the email address
  # of the newly requested account
  def send_verification_email
    AccountMailer.deliver_verify(self, resource)
  end
  
  # sends a verified email to super users indicating
  # that a user has verified their account
  def send_verified_email
    AccountMailer.deliver_verified(self, resource)
  end
  
  # sends an approval email to the email address
  # of the newly approved account
  def send_approved_email
    AccountMailer.deliver_approved(self, resource)
  end
  
public    
  def login
    if request.get?
      self.resource = find_resource
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
  
  # POST /account
  # handles the submission of new account request
  # sends verification email to requester
  def create
    self.resource = new_resource
    render :action => 'new' and return if not resource.save

    send_verification_email
    flash[:notice] = "Successfully requested account!  Email sent to #{self.resource.email_address}"
    redirect_to login_url
  end
  
  # GET /verify/:id/:v
  # handles verification links from verification emails
  # sends_verified_email on success
  def verify
    self.resource = User.verify_account(params[:id], params[:key])
  rescue Slate::UserError => e
    flash[:error] = e.message
  else
    send_verified_email
    flash[:notice] = 'Successfully verified account!  You may login once your account has been approved.'
  ensure
    redirect_to login_url
  end
  
  # GET /approve/:id/:key
  # handles approval links from verified emails
  # sends_approved_email on success
  def approve
    self.resource = User.approve_account(params[:id], params[:key])
  rescue Slate::UserError => e
    flash[:error] = e.message
  else
    send_approved_email
    flash[:notice] = 'Successfully approved account!'
  ensure
    redirect_to login_url      
  end
end