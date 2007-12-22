require 'ldap'

module Slate
  class LDAPError < StandardError; end
  class LDAPBindFailure < LDAPError; end
end

module Slate
  module LDAP
    module Attributes 
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        # lookup table which maps ActiveRecord model
        # attributes to corresponding LDAP attributes
        def ldap_lookup_table
          @lookup_table ||= {
            :first_name       => 'givenName',
            :last_name        => 'sn',
            :initial          => 'initials',
            :telephone_number => 'telephoneNumber',
            :email_address    => 'mail'
          }
        end
        
        # creates an attribute reader for a LDAP
        # attribute, which will cache the LDAP value
        # when necessary
        def ldap_attribute(*attributes)
          attributes[0] = self.ldap_lookup_table.keys if attributes[0] == :defaults
          attributes.flatten.each do |e|
            self.send(:define_method, e) do 
              # try to read a local value, and if that fails,
              # read from LDAP
              self[e] || read_ldap_attribute(e)
            end
          end
        end
      end
      
      # caches all LDAP attributes to model
      def cache_ldap_attributes
        user = Slate::LDAP.find_by_username_or_email_address(self.username)
        return if user.nil?
        
        # build a hash of attributes based on LDAP attributes
        # configured for this model
        properties = self.class.ldap_lookup_table.inject({}) do |hash, entry|
          key, value = *entry
          has_attribute?(key) ? hash.update(key => user[value].to_s) : hash
        end
        
        # save LDAP attributes to model
        update_attributes(properties)
      end

      # reads specified LDAP attribute
      def read_ldap_attribute(e)
        self.cache_ldap_attributes
        self[e]
      end   
    end
    
    # provides access to the default Rails logger
    def self.logger
      ActiveRecord::Base.logger
    end
    
    # easier access to the LDAP configuration
    # settings from Slate::Configuration
    def self.config
      Slate.config.ldap
    end
    
    # searches LDAP for user with given email address
    def self.find_by_email_address(email_address)
      query("(mail=#{email_address})")
    end
    
    # searches LDAP for user with given unique identifier
    def self.find_by_unique_identifier(unique_identifier)
      query("(uniqueIdentifier=#{unique_identifier})")
    end

    # searches LDAP for user with given username
    def self.find_by_username(username)
      query("(userPrincipalName=#{username}#{config.username_suffix})")
    end

    # searches LDAP for user having the given value
    # for either the username or email account name 
    # (in domain Slate.config.ldap.email_domain)
    def self.find_by_username_or_email_address(ue)
      query("(|(userPrincipalName=#{ue}#{config.username_suffix})(mail=#{ue}@#{config.email_domain}))")
    end
    
    # returns (creating if necesssary) a connection
    # to the LDAP server specified by Slate::Configuration
    def self.connection(bind_dn=nil, bind_password=nil)
      return @connection if @connection
      
      bind_dn, bind_password = config.bind_dn, config.password if bind_dn.nil?
      
      begin
        # connect to LDAP server and bind
        @connection = ::LDAP::Conn.new(config.host)
        @connection.bind(bind_dn, bind_password)
      rescue ::LDAP::ResultError
        raise Slate::LDAPBindFailure, 'Unable to bind to LDAP server.'
      else
        @connection  
      end
    end
    
    # resets the connection
    def self.reset_connection
      @connection = nil
    end

    # performs a query on the LDAP server
    def self.query(query)
      reset_connection
      logger.debug "LDAP query: #{query}"
      
      begin
        # search all OUs for specified username
        entry, current_ou = nil, nil
        config.ous.each do |ou|
          current_ou = ou
          connection.search("OU=#{ou},#{config.base_dn}", ::LDAP::LDAP_SCOPE_SUBTREE, query) do |r|
            entry = r.to_hash
            break
          end
        end
      rescue ::LDAP::ResultError => e
        # normally, LDAP errors during search are the
        # result of searching an invalid OU
        logger.warn "The OU '#{current_ou}' could not be found.  " +
          "Consider removing it from the Slate::Configuration.config.ldap.ous setting"
      end
        
      entry
    end

    # authenticates with LDAP using given username
    # and password, returning the hash result from
    # LDAP on success
    def self.authenticate_user(username, password)
      return nil if password.nil? || password.empty?
      return nil unless entry = find_by_username(username)
      
      # get the connection DN for the user
      user = entry['dn'][0]

      begin
        # disconnect as query user and reconnect
        # with found dn and given password
        reset_connection
        connection(user, password)
      rescue Slate::LDAPBindFailure
        # bind failed, so the user did not 
        # authenticate successfully
        nil
      else
        # only return the entry if no error
        # has occurred
        entry
      end
    end

    # authenticates with LDAP using given username
    # and password, returning true on success
    def self.authenticate(username, password)
      !authenticate_user(username, password).nil?
    end
  end
end