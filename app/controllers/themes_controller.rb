class ThemesController < ApplicationController
  resources_controller_for :theme

public
  # Installs theme
  def create
    @theme = Theme.new(params[:theme])
    @theme.install
    redirect_to resources_url
  end
end