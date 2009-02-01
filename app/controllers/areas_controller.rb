class AreasController < ApplicationController
  include Slate::Builder

  resources_controller_for :area, :in => [:space, :page],
    :only => [:edit, :update]
    
  after_filter :expire_cache, :unless => Proc.new { |c| c.request.get? }  

protected
  # override default find_resource to find by key
  def find_resource
    key = params[:key] || params[:id]
    resource_service.find_by_key(key) ||
      resource_service.build(:key => key)
  end
  
  def expire_cache
    # Slate::Caching.expire_page(resource.page) 
  end
  
public
  def update
    self.resource = find_resource
    self.resource.update_attributes(params[resource_name])
    self.resource.publish! if params[:commit] =~ /Publish/
    respond_to do |wants|
      wants.html { render :action => 'edit' }
      wants.js
    end
  end
  
  # create and update will do the same thing
  alias_method :create, :update
  
  def preview
    self.resource = find_resource
    self.resource.attributes = params[resource_name]
    respond_to do |wants|
      wants.js
    end
  end
  
  def version
    self.resource = find_resource
    self.resource = resource.versions.find_by_version(params[:version])
    respond_to do |wants|
      wants.html { render :layout => false }
    end
  end
  
  def toggle
    self.resource = find_resource
    self.resource.toggle! unless resource.new_record?
    respond_to do |wants|
      wants.html { redirect_to enclosing_resource_url }
    end
  end
  
  def destroy
    self.resource = find_resource
    resource.destroy
    respond_to do |wants|
      wants.html { redirect_to enclosing_resource_url }
    end
  end
end