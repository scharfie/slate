class LdapUser < User
  if Slate.config.ldap.enabled
    include Slate::LDAP::Attributes
    ldap_attribute :defaults
    
    before_create :ensure_ldap_user_exists
    
  protected  
    # ensures that the user exists in LDAP
    def ensure_ldap_user_exists
      unless Slate::LDAP.find_by_username_or_email_address(self.username)
        self.errors.add 'username', 'does not appear to be valid'
        return false
      end
    end
    
  public  
    # this user is an LDAP user
    def ldap_user?; true; end
    
    # use LDAP for authentication
    def authenticate(password)
      Slate::LDAP.authenticate(self.username, password)
    end
  end
end