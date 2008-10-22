class PagesController < ApplicationController
  include Slate::Builder
  include Slate::ThemeSupport
  
  resources_controller_for :pages, :in => :space
  before_filter :prepend_theme_view_paths, :only => :show
  
protected
  # creates a new page (setting the parent id
  # based on id parameter if available)
  def new_resource
    returning resource_service.new(params[resource_name]) do |page|
      page.parent_id = params[:id] if page.parent_id.blank? || page.parent_id == 0
      page.parent = resource_service.root if page.parent_id.blank?
    end
  end

public
  # grabs the root node and renders the page tree
  def index
    self.resource = resource_service.root
  end

  def show
    self.resource = find_resource
    view_page
  rescue Slate::TemplateMissing => e
    flash[:error] = e.message
    redirect_to edit_resource_url
  rescue Slate::ThemeMissing => e
    flash[:error] = e.message
    redirect_to edit_enclosing_resource_url
  end
  
  # GET organize
  def organize
    self.resource = resource_service.root
  end
  
  # def update
  #   examine params
  # end
  
  # PUT remap
  def remap
    mappings = params[:mappings]
    resource_service.remap_tree!(mappings)
    flash[:notice] = 'Successfully re-organized pages!'
    redirect_to resources_url
  end
end