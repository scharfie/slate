require 'digest/sha1'

module Slate
  class UserError < Error; end
  class CurrentSpaceError < UserError; end
  class PasswordAlreadyUsed < UserError; end
  class PasswordInvalid < UserError
    message "The given password does not match the password schema."
  end
  class PasswordIsCurrent < UserError; end
  class AccountExpired < UserError; end
  class AccountLocked < UserError
    message "This account has been locked."
  end
  class AccountNotVerified < UserError
    message "This account has not been verified." 
  end
  class AccountNotApproved < UserError
    message "This account has not been approved." 
  end
  class AccountInvalid < UserError
    message "The username and/or password is invalid." 
  end 
  class AccountVerificationInvalid < UserError; end
  class AccountApprovalInvalid < UserError; end
  class AccountAlreadyVerified < UserError; end
  class AccountAlreadyApproved < UserError; end
  class SuperUserRequiredForApproval < UserError; end
end


class User < ActiveRecord::Base
  validates_uniqueness_of :username, :email_address
  attr_protected :super_user
  cattr_accessor :active
  attr_accessor :temporary_password
  
  has_many :memberships
  has_many :spaces, :through => :memberships, :select => 'spaces.*, memberships.role AS role'

  validates_presence_of :first_name, :last_name, :email_address, :reason_for_account, 
    :on => :create, :if => Proc.new { |user| !user.ldap_user? }

  before_validation :ensure_username

protected
  # ensures that the username attribute is set
  # (optionally setting it to a generated value)
  def ensure_username
    self.username ||= self.class.generate_username(self)
  end

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

public
  # authenticates with the given credentials
  # return: user on success
  #         nil if no user is found
  #         false if authentication is invalid
  def self.login(*args)
    username, password = extract_credentials(*args)
    
    return nil if (user = find_by_username(username)).nil?
    
    raise Slate::AccountLocked if user.locked?
    raise Slate::AccountNotVerified unless user.verified?
    raise Slate::AccountNotApproved unless user.approved?

    user.authenticate(password) ? process_valid_login(user) : process_invalid_login(user)
  end
  
  # performs a login() but raises Slate::AccountInvalid 
  # if the login fails (i.e. result is nil or false)
  def self.login!(*args)
    login(*args) or raise Slate::AccountInvalid
  end
  
  # finds user given a username or ID
  def self.find_user(username_or_id)
    user = username_or_id =~ /^\d+$/ ? self.find_by_id(username_or_id) : self.find_by_username(username_or_id)
  end
  
  # verifies the given account with the specified
  # verification key
  def self.verify_account(username_or_id, verify_key)
    user = find_user(username_or_id)
    
    # skip verfication if 'require_verification' is disabled
    return user if Slate.config.users.require_verification == false
    
    raise Slate::AccountInvalid if user.nil?
    return user if user.verified?
    raise Slate::AccountVerificationInvalid unless user.verification_key == verify_key
    
    user.update_attribute(:verified_on, Time.now)
    user
  end

  # approves the given account
  def self.approve_account(username_or_id, approval_key)
    user = find_user(username_or_id)
    
    # skip approval if 'require_approval' is disabled
    return user if Slate.config.users.require_approval == false
    
    raise Slate::AccountInvalid if user.nil?
    raise Slate::AccountNotVerified unless user.verified?
    raise Slate::AccountAlreadyApproved if user.approved?
    raise Slate::AccountApprovalInvalid unless user.approval_key == approval_key
    raise Slate::SuperUserRequiredForApproval if User.active.nil? || !User.active.super_user?

    user.update_attributes(:approved_on => Time.now, :approved_by => User.active.username)
    user
  end

  # requests a new account based on given attributes
  def self.request_account(params)
    returning self.new(params) do |user|
      user.requested_on = params[:requested_on] || Time.now
      user.username ||= self.generate_username(user)
      user.save
    end
  end
  
  # checks to see if the given password is valid
  # based on the following rules:
  #   Your password must:
  #   1. Be at least eight characters in length 
  # - 2. Not contain all or part of the user's account name 
  #   3. Contain characters from three of the following four categories:
  #     a. English uppercase characters (A through Z)
  #     b. English lowercase characters (a through z)
  #     c. Base 10 digits (0 through 9) 
  #     d. Nonalphanumeric characters (e.g., !, $, #, %)
  def self.valid_password?(pw)
    return false if pw.length < 8
    pass, rules = 0, [/[A-Z]/, /[a-z]/, /[0-9]/, /[!@#\$%]/]
    rules.each { |re| pass += 1 if pw =~ re }
    pass >= 3
  end

  # encrypts the password using SHA1 
  # uses the password_salt defined in the 
  # configuration if available
  def self.encrypt_password(pw)
    pw.length == 40  ? pw : Digest::SHA1.hexdigest((Slate.config.users.password_salt || '') + pw) 
  end
  
  # generates a local user account username
  # based on a the name of the supplied user
  # 
  # Format:
  #   [first letter of first name][initials][lastname]
  def self.generate_username(user_object)
    parts = [
     (user_object.first_name || '').blank? ? '' : user_object.first_name[0].chr,
     user_object.initial || '', 
     user_object.last_name
    ]
    
    parts.compact.join('').downcase
  end
  
  # generates verification key for the given user
  def self.generate_verification_key(user_object)
    Digest::SHA1.hexdigest(user_object.username + user_object.requested_on.to_i.to_s)    
  end

  # generates approval key for the given user
  def self.generate_approval_key(user_object)
    Digest::SHA1.hexdigest(user_object.username + user_object.verified_on.to_i.to_s)    
  end

  # generates a random password
  def self.generate_password
    values = ['A'..'Z', 'a'..'z', '0'..'9'].map(&:to_a).flatten
    password, size = [], 8

    # seed the time
    srand Time.now.usec
    
    # create the initial password
    size.times { password << values[rand(values.length)].downcase }
    
    # pick random points in the password string to modify
    keypoints = []
    keypoints << rand(8) while (keypoints = keypoints.uniq).length < 3
    
    password[keypoints[0]] = values[rand(26)]
    password[keypoints[1]] = values[rand(26) + 26]
    password[keypoints[2]] = values[rand(10) + 52]
        
    password.join
  end

  # returns email addresses for all super users  
  def self.super_user_email_addresses
    self.find(:all,
      :conditions => ['super_user = ?', true]
    ).map { |e| e.email_address }    
  end

  # returns the time the user requested an account
  # (defaults to created_on or current time)
  def requested_on
    super || self.created_on || Time.now.to_i
  end
  
  # logs the user out (sets the active user to nil)
  def logout
    User.active = nil
  end
  
  # returns the user's first and last name
  def display_name
    [first_name, last_name].compact.join(' ')
  end
  
  # returns user's role for the given site
  # (defaults to the active site)
  def role(site=nil)
    (self[:role] ||= self.memberships.role(site, self)).to_i
  end
  
  # returns true if the user is mapped to an ldap account
  def ldap_user?
    [self.class.to_s, self[:type]].include? 'LdapUser'
  end
  
  # the password field will hold the verification 
  # key until the account is verified
  def verification_key
    verified? ? nil : self.class.generate_verification_key(self)
  end
  
  def approval_key
    verified? ? self.class.generate_approval_key(self) : nil
  end
  
  # returns true if the account has been approved
  def approved?
    Slate.config.users.require_approval == false || !self.approved_on.nil?
  end

  # returns true if the account has been verified
  def verified?
    Slate.config.users.require_verfication == false || !self.verified_on.nil?
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
  
  # sets the temporary password (clear-text)
  # and sets the password to the encrypted form
  def temporary_password=(pw)
    self.password = @temporary_password = pw
  end
  
  # sets the encrypted password if it's valid
  def password=(pw)
    raise Slate::PasswordInvalid unless self.class.valid_password?(pw)
    self[:password] = self.class.encrypt_password(pw)
  end
  
  # authenticate user with given password
  def authenticate(password)
    self.password == self.class.encrypt_password(password)
  end
end