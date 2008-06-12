require File.dirname(__FILE__) + '/../spec_helper'
require 'ostruct'

describe Plugin do
  before(:each) do
    @plugin = Plugin.new(:key => 'A')
    Slate.plugins = [@slate_plugin = OpenStruct.new(
      :key => 'A',
      :name => 'Plugin A',
      :description => 'This is the A plugin'
    )]
  end
  
  after(:all) do
    Slate.plugins = []
  end

  it 'should find slate plugin A' do
    @plugin.slate_plugin.should == @slate_plugin
  end

  it 'should read name via delegate' do
    @plugin.name.should == 'Plugin A'
  end

  it 'should read description via delegate' do
    @plugin.description.should == 'This is the A plugin'
  end
end