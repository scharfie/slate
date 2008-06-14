require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  attr_accessor :erb_output

  before(:each) do
    assigns[:controller] = self
  end
  
  def helper_variable(v)
    helper.instance_variable_get(v)
  end
  
  def helper_variable_set(v, value=nil)
    helper.instance_variable_set(v, value)
  end
  
  it "should store content for book_collection using string" do
    helper_variable_set :@content_for_book_collection
    lambda { helper.content_for_variable('book_collection', 'Programming Ruby') }.
      should change { helper_variable :@content_for_book_collection }.from(nil).to('Programming Ruby')
  end
  
  it "should store content for book_collection using block" do
    helper_variable_set :@content_for_book_collection
    lambda { helper.content_for_variable('book_collection') { helper.concat('Programming Ruby') } }.
      should change { helper_variable :@content_for_book_collection }.from(nil).to('Programming Ruby')
  end
  
  it "should store content for book_collection using string and block" do
    helper_variable_set :@content_for_book_collection    
    lambda { helper.content_for_variable('book_collection', 'Programming ') { helper.concat('Ruby') } }.
      should change { helper_variable :@content_for_book_collection }.from(nil).to('Programming Ruby')
  end
  
  it "should store content for heading using string and block" do
    lambda { helper.heading('My ') { helper.concat('Heading') } }.
      should change { helper_variable :@content_for_heading }.from(nil).to('My Heading')
  end

  it "should store content for head using string and block" do
    lambda { helper.head('Hello ') { helper.concat('Chris') } }.
      should change { helper_variable :@content_for_head }.from(nil).to('Hello Chris')
  end
  
  it "should render space chooser" do
    @spaces = []
    Space.should_receive(:find).with(:all, :order => 'name').and_return(@spaces)
    helper.should_receive(:render).with(:partial => 'shared/space_chooser', :locals => { :spaces => @spaces})
    helper.space_chooser
  end
  
  it "should create a cancel link" do
    helper.should_receive(:link_to).with('Cancel', {:controller => 'dashboard' }, :class => 'cancel')
    helper.cancel_link(:controller => 'dashboard')
  end
  
  it "should create a cancel link for current resources url" do
    helper.should_receive(:resources_url).and_return('/spaces/1/pages')
    helper.should_receive(:link_to).with('Cancel', '/spaces/1/pages', :class => 'cancel')
    helper.cancel_link
  end
  
  it "should create an image tag for glyph 'exclamation'" do
    @image = helper.glyph('exclamation')
    @image.should include('/images/glyphs/exclamation.png')
    @image.should include('class="glyph"')
  end

  it "should create an image tag for glyph 'exclamation' with options" do
    @image = helper.glyph('exclamation', :class => 'my_class', :alt => 'Custom alt')
    @image.should include('/images/glyphs/exclamation.png')
    @image.should include('class="my_class glyph"')
    @image.should include('alt="Custom alt"')
  end
  
  it "should escape the given javascript" do
    @javascript = <<-JS
    alert("Hello, 'Chris'!");}
    JS
    helper.js(@javascript).should == escape_javascript(@javascript)
  end
  
  it "should create span tag" do
    helper.span('chrisscharf').should == '<span>chrisscharf</span>'
    helper.span('chrisscharf', :class => 'name').should == 
      '<span class="name">chrisscharf</span>'
  end
  
  it "should return 'slate' link to dashboard" do
    helper.should_receive(:link_to).with('slate', '/dashboard').and_return('<a href="/dashboard">slate</a>')
    helper.should_receive(:span).with('<a href="/dashboard">slate</a>', :class => 'slate')
    helper.dashboard_heading
  end
  
  it "should return nothing for space heading with no active space" do
    Space.should_receive(:active).and_return(nil)
    helper.space_heading.should == nil
  end
  
  it "should return link to active space" do
    Space.stub!(:active).and_return(@space = mock(Space))
    @space.stub!(:to_param).and_return(155)
    @space.stub!(:name).and_return('Demo site')
    helper.space_heading.should == 
      '<span class="space"><a href="/spaces/155/dashboard">Demo site</a></span>'
  end
  
  it "should return 'Administrator' span when super user" do
    helper.should_receive(:super_user?).and_return(true)
    helper.admin_heading.should == 
      '<span class="space">Administrator</span>'
  end

  it "should return nothing when not super user" do
    helper.should_receive(:super_user?).and_return(false)
    helper.admin_heading.should == nil
  end

end