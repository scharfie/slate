module Slate
  module Authentication
    # before filter which assigns active user based on 
    # session.  If no user is found, a redirect to the 
    # login screen occurs
    # 
    # Note that this filter returns true if the request
    # isn't from slate (see the +slate?+ method)
    def capture_user!
      return true unless slate?
    
      unless capture_user
        flash[:notice] = "Please sign in first and then we'll take you back."
        session[:redirect_to] = url_for(:only_path => false)
        redirect_to login_url() and return false
      end
    end
  
    # Attempts to login user
    def capture_user
      login_from_session || login_from_cookie
    end
  
    # Assigns active user based on session
    def login_from_session
      self.current_user = User.find_by_id(session[:user_id])
    end
  
    # Assigns active user based on cookie
    def login_from_cookie
      return nil if cookies[:auth_token].nil?
      save_login_cookie if self.current_user = User.find_by_remember_token(cookies[:auth_token])
      current_user
    end

    # Returns the current user
    def current_user
      User.active
    end
  
    # Sets the current user
    def current_user=(v)
      User.active = v
    end
  
    # Return true if user is logged in
    def logged_in?
      !User.active.nil?
    end
  
    # Saves/updated the login cookie 
    def save_login_cookie
      current_user.remember_me!
      cookies[:auth_token] = current_user.remember_token_as_cookie
    end
  
    # Logs out the current user (removes cookie, forgets user, etc.)
    def logout_current_user
      cookies.delete :auth_token
      current_user.forget_me! if logged_in?
      self.current_user = nil if logged_in?
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
      unless super_user?
        flash[:error] = "Super user is required to perform this task."
        session[:redirect_to] = url_for(:only_path => false)
        redirect_to login_url() and return false
      end
    end
    
    # Returns true if the active user is a super user
    def super_user?
      User.active && User.active.super_user? || false
    end
    
    # Returns true if the first subdomain is slate
    def slate?
      request.subdomains.first == 'slate'    
    end

    def self.included(base)
      base.send :helper_method, :super_user?, :slate?
    end
  end
end