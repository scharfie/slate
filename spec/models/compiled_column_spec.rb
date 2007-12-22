require File.dirname(__FILE__) + '/../spec_helper'

Object.send :remove_const, :CompiledColumnTestClass rescue nil

class CompiledColumnTestClass
  include Slate::CompiledColumn
  attr_accessor :body, :subject
  
  def [](attr)
    self.instance_variable_get("@#{attr}")
  end
  
  def []=(attr, value)
    self.instance_variable_set("@#{attr}", value)
  end
  
  def self.before_save(*args); end
end

class CompiledColumnUpcaseCompiler
  def initialize(data, options)
    @data = data
    @options = options
  end
  
  def to_html
    @data.upcase
  end
  
  def options
    @options
  end
end

describe 'Slate::CompiledColumn' do
  before(:each) do
    @klass = CompiledColumnTestClass.new
    @klass.class.compiled_column :body
  end
  
  it "should return compiled content for body_html" do
    @klass.body = '*Compiled* column'
    @klass.body_html.should == '<p><strong>Compiled</strong> column</p>'
  end
  
  it "should use custom compiler for subject_html" do
    @klass.subject = 'Test subject'
    @klass.class.compiled_column :subject, :compiler => CompiledColumnUpcaseCompiler
    @klass.subject_html.should == "TEST SUBJECT"
  end
end