require File.dirname(__FILE__) + '/../spec_helper'

if perform_ldap_testing?

def testuser
  Slate.config.ldap.testuser
end

describe Slate::LDAP do
  before(:each) do
    @connection = Slate::LDAP.connection    
  end
  
  it "should connect successfully" do
    @connection.should be_a_kind_of(::LDAP::Conn)
    @connection.bound?.should == true
  end
  
  it "should reset connection" do
    Slate::LDAP.reset_connection
    Slate::LDAP.instance_variable_get(:@connection).should == nil
  end
end

describe Slate::LDAP, "with invalid OU" do
  it "should log warning" do
    previous_ous = Slate.config.ldap.ous
    Slate.config.ldap.ous = %w(invalid-ou)
    
    Slate::LDAP.reset_connection
    Slate::LDAP.logger.should_receive('warn').with(/The OU 'invalid-ou' could not be found/)
    Slate::LDAP.find_by_username(testuser.username)
    
    Slate.config.ldap.ous = previous_ous
  end
end

describe Slate::LDAP, "bind with invalid credentials" do
  before(:each) do
    Slate::LDAP.reset_connection
  end
  
  it "should fail with wrong bind DN and password" do
    lambda { 
      Slate::LDAP.connection('invalid-bind-dn', 'invalid-password') 
    }.should raise_error(Slate::LDAPBindFailure)
  end
  
  it "should fail with wrong password" do
    lambda { 
      Slate::LDAP.connection(Slate.config.ldap.bind_dn, 'invalid-password') 
    }.should raise_error(Slate::LDAPBindFailure)
  end
end

describe Slate::LDAP, 'with stubbed query' do
  before(:each) do
    Slate::LDAP.stub!(:query)
  end
  
  it "should search for email address" do
    Slate::LDAP.should_receive(:query).with('(mail=cbscharf@example.com)')
    Slate::LDAP.find_by_email_address('cbscharf@example.com')
  end
  
  it "should search for unique identifier" do
    Slate::LDAP.should_receive(:query).with('(uniqueIdentifier=123456789)')
    Slate::LDAP.find_by_unique_identifier('123456789')
  end
  
  it "should search for username" do
    Slate::LDAP.should_receive(:query).with("(userPrincipalName=cbscharf#{Slate.config.ldap.username_suffix})")
    Slate::LDAP.find_by_username('cbscharf')
  end

  it "should search for username or email address" do
    Slate::LDAP.should_receive(:query).with("(|(userPrincipalName=cbscharf#{Slate.config.ldap.username_suffix})(mail=cbscharf@#{Slate.config.ldap.email_domain}))")
    Slate::LDAP.find_by_username_or_email_address('cbscharf')
  end
end

describe Slate::LDAP::Attributes do
  before(:each) do
    @klass = Class.new
    @klass.send :include, Slate::LDAP::Attributes
  end
  
  it "should create default LDAP attribute accessors" do
    methods = [:first_name, :initial, :last_name, :telephone_number, :email_address]
    methods.each { |m| @klass.new.should_not respond_to(m) }
    @klass.ldap_attribute :defaults
    methods.each { |m| @klass.new.should respond_to(m) }
  end
  
  it "should create LDAP attribute accessor for first_name" do
    @klass.new.should_not respond_to(:first_name)
    @klass.ldap_attribute :first_name
    @klass.new.should respond_to(:first_name)
  end
end

describe Slate::LDAP::Attributes do
  before(:each) do
    @klass = Class.new
    @klass.send :include, Slate::LDAP::Attributes
    @klass.ldap_attribute :defaults
    @object = @klass.new
    @object.stub!(:[])
  end

  it "should return cached value for 'first_name'" do
    @object.should_receive(:[]).with(:first_name).and_return('Chris')
    @object.first_name.should == 'Chris'
  end 
  
  it "should read from LDAP for 'last_name'" do
    @object.should_receive(:read_ldap_attribute).with(:last_name).and_return('ldap_last_name')
    @object.last_name.should == 'ldap_last_name'
  end
end

end # perform_ldap_testing?