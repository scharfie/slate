class AssetsController < ApplicationController
  resources_controller_for :assets, :in => :space

public
  def extract
    self.resource = find_resource
    self.resource.extract!
    redirect_to resources_url
  end
end