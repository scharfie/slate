require File.join(File.dirname(__FILE__), '../spec_helper')

module FormAssistantHelpers
  attr_accessor :render_options
  def render(options={})
    self.render_options = options
    String.new
  end

  def locals
    render_options[:locals] rescue {}
  end

  def expect_render(options={})
    hash_including(options).should == render_options
  end

  def expect_locals(options={})
    hash_including(options).should == locals
  end    
end

describe "FormAssistant" do
  include FormAssistantHelpers
  include RPH::FormAssistant::ActionView
  
  attr_accessor :form, :output_buffer
  
  
  before(:each) do
    @output_buffer = ''
    @address_book = OpenStruct.new
    @address_book.stub!(:errors).and_return(@errors ||= ActiveRecord::Errors.new(@address_book))

    @form = RPH::FormAssistant::FormBuilder.new(:address_book, @address_book, self, {}, nil)
    RPH::FormAssistant::FormBuilder.template_root = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'forms'))
  end
  
  it "should use template based on input type" do
    form.text_field :first_name
    expect_render :partial => 'forms/text_field'
  end
  
  it "should use fallback template if no specific template is found" do
    form.text_field :first_name, :template => 'fancy_template_that_does_not_exist'
    expect_render :partial => "forms/#{form.fallback_template}"
  end
  
  it "should render a valid field" do
    form.text_field :first_name
    expect_locals :errors => nil
  end
  
  it "should render an invalid field" do
    @address_book.errors.add(:first_name, 'cannot be root')
    form.text_field :first_name
    expect_locals :errors => 'First name cannot be root'
  end
  
  it "should render a field with a tip" do
    form.text_field :nickname, :tip => 'What should we call you?'
     expect_locals :tip => 'What should we call you?' 
  end
  
  it "should create fieldset" do
    fieldset('Information') { "fields-go-here" }
    expect_render :partial => 'forms/fieldset'
    expect_locals :legend => 'Information',
      :fields => 'fields-go-here'
  end
end