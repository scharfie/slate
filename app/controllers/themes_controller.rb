class ThemesController < ApplicationController
  resources_controller_for :theme

public
  # Refreshes theme (SCM 'update')
  def refresh
    @theme = Theme.find(params[:id])
    result = @theme.update
    render :text => result
  end

  # Installs theme
  def create
    @theme = Theme.new(params[:theme])
    @theme.install
    redirect_to resources_url
  end
end