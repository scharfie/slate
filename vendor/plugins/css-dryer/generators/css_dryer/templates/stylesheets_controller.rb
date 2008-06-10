class StylesheetsController < ApplicationController
  before_filter :set_headers
  after_filter { |controller| controller.cache_page }
  session :off
  layout nil

  private

  def set_headers
    headers['Content-Type'] = 'text/css; charset=utf-8'
  end
end
