require File.dirname(__FILE__) + '/../spec_helper'

# Let's just be clear - this spec is one nasty
# hack-fest.  Unfortunately, I couldn't find an easier
# way of testing form builders.

Object.send :remove_const, :AddressBookModel rescue nil

class AddressBookModel
  attr_accessor :first_name, :last_name, :country
  def errors; @errors ||= ActiveRecord::Errors.new(self); end
end

# custom controller to fake out rendering
class BuilderHelperController < ActionController::Base
  attr_accessor :template
  
  def initialize
    super
    @template = ::ActionView::Base.new
    @template.view_paths = self.class.view_paths
    @assigns = {}
  end
  
  def response
    @response ||= ::ActionController::AbstractResponse.new
  end
end

describe Slate::FormBuilder do
  attr_accessor :render_options, :controller, :erb_output
  attr_accessor :builder_options
  attr_accessor :assume_templates_exist
  
  before(:each) do
    self.erb_output = ''
    @address_book = AddressBookModel.new
    @render_options = {}
    
    # begin hacking (not _too_ bad)
    @controller = BuilderHelperController.new
    @template = @controller.template
    
    @builder_options = {}
    @assume_templates_exist = false
  end
  
  # stub out render to simply record the rendering options
  def render(*args)
    self.render_options = *args
    controller.send(:render, *args) unless self.assume_templates_exist
  end
  
  # simpler accessor for the :locals rendering option
  def locals
    self.render_options[:locals]
  end
  
  # executes the block in the context of a new Slate::FormBuilder
  def form_builder(&block)
    builder = Slate::FormBuilder.new('address_book', @address_book, self, {}, block)
    builder.options.merge! self.builder_options
    yield builder
  end
  
  # builds the given helper with Slate::FormBuilder
  def build(helper, *args)
    form_builder do |f|
      f.send(helper, *args)
    end  
  end

  it "should create text field" do
    build :text_field, :first_name
    
    render_options[:partial].should == 'forms/element'
    locals[:tip].should be_blank
    locals[:errors].should be_blank
    locals[:label].should include('First name')
  end

  it "should create text field with custom label" do
    build :text_field, :first_name, :label => 'Given name'
    
    render_options[:partial].should == 'forms/element'
    locals[:tip].should be_blank
    locals[:errors].should be_blank
    locals[:label].should include('Given name')
  end

  it "should create text field and render with custom template" do
    self.assume_templates_exist = true
    build :text_field, :first_name, :template => 'my_custom_template'
    
    render_options[:partial].should == 'forms/my_custom_template'
    locals[:tip].should be_blank
    locals[:errors].should be_blank
  end
  
  it "should create text field and render with custom template and label via default options" do
    begin
      self.builder_options = { :default_template => 'my_default_template', :label_append => ': '}
      build :text_field, :first_name, :label => 'Given name'
    rescue ActionView::ActionViewError
      # we have to trap missing template errors 
      # here because my_default_template
      # doesn't actually exist
    end
    
    render_options[:partial].should == 'forms/my_default_template'
    locals[:tip].should be_blank
    locals[:errors].should be_blank
    locals[:label].should include('Given name: ')
  end
  
  it "should create text field with custom tip" do
    build :text_field, :first_name, :tip => 'This is your first name'
    
    render_options[:partial].should == 'forms/element'
    locals[:tip].should include('This is your first name')
    locals[:errors].should be_blank
  end    
  
  it "should create an 'actions' DIV" do
    current_binding = binding
    
    form_builder do |f|
      f.actions do
        concat submit_tag('Save changes'), current_binding
      end
    end
    
    erb_output.should include('<div class="actions">')
    erb_output.should include('Save changes')
  end
end