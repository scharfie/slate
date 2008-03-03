require File.dirname(__FILE__) + '/../spec_helper'

Object.send(:remove_const, :RoutingTestController) rescue

class RoutingTestController < ActionController::Base
end

describe "Slate::Routing" do
  controller_name 'RoutingTest'
  attr_accessor :route
  
  def public_route_for(*args)
    ActionController::Routing::Routes.draw do |map|
      map.public_routes { |m| self.route = m.connect(*args) }
    end
    
    return route
  end

  def with_space_resources_for(*args)
    ActionController::Routing::Routes.draw do |map|
      map.with_space { |m| m.resources(*args) }
    end
  end
  
  after(:each) do
    ActionController::Routing::Routes.reload
  end
  
  it "should map public route /hello" do
    @route = public_route_for '/hello'
    @route.conditions[:not_subdomain].should == 'slate'
    @route.requirements[:controller].should == 'public'
  end
  
  it "should map resources Boxes with space" do
    with_space_resources_for 'boxes'
    options = { :space_id => 700, :controller => 'boxes'}

    route_for(options.merge(:action => "index")).should == "/spaces/700/boxes"
    route_for(options.merge(:action => "new")).should == "/spaces/700/boxes/new"
    route_for(options.merge(:action => "show", :id => 'junk')).should == "/spaces/700/boxes/junk"
    route_for(options.merge(:action => "edit", :id => 'junk')).should == "/spaces/700/boxes/junk/edit"
    route_for(options.merge(:action => "update", :id => 'junk')).should == "/spaces/700/boxes/junk"
    route_for(options.merge(:action => "destroy", :id => 'junk')).should == "/spaces/700/boxes/junk"
  end
end