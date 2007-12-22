require File.dirname(__FILE__) + '/../spec_helper'

describe Membership, "between 'cbscharf' and 'test_space'" do
  fixtures :users, :spaces, :memberships
  
  before(:each) do
    @membership = memberships(:cbscharf_test_space)
  end

  it "should exist" do
    @membership.user.should == users(:cbscharf)
    @membership.space.should == spaces(:test_space)
  end
  
  it "should have role == 1" do
    @membership.role.should == 1
  end
end

describe Membership, "between 'cbscharf' and 'admin_space'" do
  fixtures :users, :spaces, :memberships
  
  before(:each) do
    @membership = memberships(:cbscharf_admin_space)
  end

  it "should exist" do
    @membership.user.should == users(:cbscharf)
    @membership.space.should == spaces(:admin_space)
  end
  
  it "should have role == 2" do
    @membership.role.should == 2
  end
end

describe Membership do
  fixtures :users, :spaces, :memberships
  
  before(:each) do
    @test_space = spaces(:test_space)
    @cbscharf = users(:cbscharf)
  end
  
  it "should find membership for 'cbscharf' on 'test_space'" do
    @membership = Membership.find_membership(@test_space, @cbscharf)
    @membership.user.should == @cbscharf
    @membership.space.should == @test_space
  end
  
  it "should find membership for active user and space" do
    Space.active = @test_space
    User.active = @cbscharf
    
    @membership = Membership.find_membership()
    @membership.user.should == @cbscharf
    @membership.space.should == @test_space
  end
end

describe "New membership between 'dmolsen' and 'admin_space'" do
  fixtures :users, :spaces, :memberships
  
  before(:each) do
    @admin_space = spaces(:admin_space)
    @dmolsen = users(:dmolsen)
    
    @membership = Membership.create(:user => @dmolsen, 
      :space => @admin_space,
      :role => 2
    )
  end
  
  it "should be valid" do
    @membership.valid?.should == true
    @membership.user.should == @dmolsen
    @membership.space.should == @admin_space
    
    @dmolsen.spaces.should include(@admin_space)
    @admin_space.users.should include(@dmolsen)
  end
  
  it "should have role == 2" do
    @membership.role.should == 2
    
    Membership.role(@admin_space, @dmolsen).should == 2
  end
end