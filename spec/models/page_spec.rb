require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  fixtures :pages
  it "should be created" do
    @page = Page.create(:name => 'My Test Page', :space_id => 1)
    Page.count.should == 2
    
    @page.should be_valid
    @page.parent_id.should == 1
    @page.reload
    @page.parent.should_not be_nil
    
    @page.permalink.should == 'my_test_page'
  end
end

describe Page do
  fixtures :pages, :spaces
  
  before(:each) do
    # the following creates WV > Morgantown > 1 Fine Arts Drive
    @space = spaces(:test_space)
    @wv = @space.pages.create!(:name => 'WV', :is_default => true)
    @morgantown = @space.pages.create!(:name => 'Morgantown')
    @wv.children << @morgantown
    @address = @space.pages.create!(:name => '1 Fine Arts Drive', :is_hidden => true)
    @morgantown.children << @address
    
    @wv.reload
    @morgantown.reload
    @address.reload
  end

  it "should return 'WV' via find_by_page_path" do
    Page.find_by_page_path('wv').should == @wv
  end
  
  it "should return 'Morgantown' via find_by_page_path" do
    Page.find_by_page_path('wv/morgantown').should == @morgantown
    Page.find_by_page_path(%w(wv morgantown)).should == @morgantown
  end
  
  it "should return '1 Fine Arts Drive' via find_by_page_path" do
    Page.find_by_page_path(%w(wv morgantown 1_fine_arts_drive)).should == @address
  end
  
  it "should return path names" do
    @address.path_names.should == ['WV', 'Morgantown', '1 Fine Arts Drive']
  end
  
  it "'WV' should be default page" do
    @wv.should be_default
    @space.default_page.should == @wv
  end
  
  it "'Morgantown' should become default page" do
    @space.default_page.should == @wv
    @morgantown.update_attribute(:is_default, true)
    @space.default_page.should == @morgantown
    @wv.reload
    @wv.should_not be_default
    @morgantown.should be_default
  end
  
  it "'1 Fine Arts Drive' should be hidden" do
    @address.should be_hidden
  end
  
  it "should return proper permalinks" do
    @wv.permalink.should == 'wv'
    @morgantown.permalink.should == 'morgantown'
    @address.permalink.should == '1_fine_arts_drive'
    
    @p = Page.new(:name => 'This IS SomethinG CRAZY!!!!')
    @p.permalink.should == 'this_is_something_crazy'
  end
end

describe Page do
  fixtures :pages, :spaces, :areas, :users

  before(:each) do
    User.active = users(:cbscharf)
    Space.active = spaces(:test_space)
    
    @space = spaces(:test_space)
    @home = @space.pages.create(:name => 'Home')
    @about = @space.pages.create(:name => 'About')
    
    # create default content for @header
    @header = @home.content_for(:header)
    @header.update_attributes(:body => 'HeaderContent', :is_default => true)
  end
  
  it "should return default content from Home for About/header" do
    @about.content_for(:header).should == @header
  end
  
  it "should return custom content for About/header" do
    @area = @about.areas.create!(:key => 'header', :body => 'CustomHeaderContent')
    @about.content_for(:header).should == @area
  end
  
  it "should return default content for About/header in production" do
    @published_header = @header.publish!
    @about.content_for(:header, :production).should == @published_header
  end
  
  it "should return custom content for About/header in production" do
    @area = @about.areas.create!(:key => 'header', :body => 'CustomHeaderContent')
    @published_header = @header.publish!
    @published_area = @area.publish!
    @about.content_for(:header, :production).should == @published_area
  end
end

describe "Pages collection in space" do
  fixtures :pages, :spaces
  
  before(:each) do
    @space = spaces(:test_space)
  end
  
  it "should auto-create root" do
    @space.pages.size.should == 0
    @space.pages.create(:name => 'My test page')
    @space.pages(true).size.should == 2
  end
end