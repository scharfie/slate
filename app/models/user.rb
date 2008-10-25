require 'digest/sha1'

module Slate
  class UserError < Error; end
  class CurrentSpaceError < UserError; end
  class AccountLocked < UserError
    message "This account has been locked."
  end
  class AccountInvalid < UserError
    message "The username and/or password is invalid." 
  end 
end

class User < ActiveRecord::Base
  # Attributes
  attr_accessor :remember_me
  attr_protected :super_user
  cattr_accessor :active
  attr_accessor :password
  
  # Associations
  has_many :memberships
  has_many :spaces, :through => :memberships, :select => 'spaces.*, memberships.role AS role'

  # Callbacks
  before_save :encrypt_password

  # Validations
  validates_presence_of :password_confirmation, :if => Proc.new { |user| !user.password.blank? }
  validates_confirmation_of :password, :if => Proc.new { |user| !user.password.blank? }
  validates_uniqueness_of :username, :email_address
  validates_presence_of :email_address, :on => :create

protected
  # extracts username and password from given
  # arguments (either directly or from first
  # argument if it's a hash)
  def self.extract_credentials(*args)
    if Hash === (params = args.first)
      [params[:username], params[:password]]
    else
      args[0..1]
    end
  end

  # resets the login attempts counter, updates the 
  # last login time and makes the given user active
  def self.process_valid_login(user)
    user.update_attributes(:login_attempts => 0, :last_login => Time.now)
    User.active = user
  end
  
  # increments the login attempts counter, locking
  # the account if necessary (which will raise Slate::AccountLocked)
  # return: false
  def self.process_invalid_login(user)
    user.increment!(:login_attempts)
    user.lock_account if user.login_attempts >= Slate.config.users.login_attempts
    raise Slate::AccountLocked if user.locked?
    return false
  end

  # Raises Slate::AccountLocked if the account is locked
  def self.account_active?(user)
    raise Slate::AccountLocked if user.locked?
  end
  
public
  # authenticates with the given credentials
  # return: user on success
  #         nil if no user is found
  #         false if authentication is invalid
  def self.login(*args)
    username, password = extract_credentials(*args)
    return nil if (user = find_by_username(username)).nil?
    
    # Check that the user account is active
    account_active? user

    user.authenticate(password) ? process_valid_login(user) : process_invalid_login(user)
  end
  
  # performs a login() but raises Slate::AccountInvalid 
  # if the login fails (i.e. result is nil or false)
  def self.login!(*args)
    login(*args) or raise Slate::AccountInvalid
  end
  
  # finds user given a username or ID
  def self.find_user(username_or_id)
    user = username_or_id.to_s =~ /^\d+$/ ? self.find_by_id(username_or_id) : self.find_by_username(username_or_id)
  end
  
  # encrypts the value using SHA1 
  # uses the password_salt defined in the 
  # configuration if available
  def self.encrypt(value)
    Digest::SHA1.hexdigest((Slate.config.users.password_salt || '') + value) 
  end

  # returns email addresses for all super users  
  def self.super_user_email_addresses
    self.find(:all,
      :conditions => ['super_user = ?', true]
    ).map { |e| e.email_address }    
  end

  # logs the user out (sets the active user to nil)
  def logout
    User.active = nil
  end
  
  # returns the user's first and last name
  def display_name
    [first_name, last_name].compact.join(' ')
  end
  
  def name
    display_name.blank? ? username : display_name
  end
  
  # returns user's role for the given site
  # (defaults to the active site)
  def role(site=nil)
    (self[:role] ||= self.memberships.role(site, self)).to_i
  end
  
  # returns true if the account is locked
  def locked?
    self[:locked] == true
  end
  
  # locks the account
  def lock_account
    self.update_attribute(:locked, true)  
  end
  
  # unlocks the account
  def unlock_account
    self.update_attributes(:locked => false, :login_attempts => 0)
  end  
  
  # before save which encrypts the password
  def encrypt_password
    return if password.blank?
    self.crypted_password = self.class.encrypt(password)
  end
  
  # Authenticate user with given password
  def authenticate(password)
    self.crypted_password == self.class.encrypt(password)
  end
  
  # The following 'remember' methods were taken from 
  # restful_authentication and modified

  # Returns true if the user has a valid remember token
  # (token that hasn't expired)
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for 
  # remembering users between browser closes
  def remember_me!
    remember_me_for 2.weeks
  end
  
  # Returns true if the remember_me attribute is on
  def remember_me?
    (remember_me || 0).to_i == 1
  end

  # Remember user for duration of time
  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  # Remember user until given time
  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = self.class.encrypt("#{email_address}--#{remember_token_expires_at}")
    save(false)
  end
  
  # Forget this user by clearing and token
  def forget_me!
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end    
  
  def remember_token_as_cookie
    { :value => remember_token, :expires => remember_token_expires_at } if remember_token?
  end
end