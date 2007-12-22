class PublicController < ApplicationController
  # we don't need to capture a user for the public side
  skip_before_filter :capture_user!
  
protected
  def capture_space
    @space = Space.active = Space.find_by_domain(request.host)
  end
  
public
  def index
    path = params[:page_path]
    render :text => <<-HTML
      <h1>TODO: render public side for path:</h1>
        <strong>Domain:</strong>#{request.host}<br />
        <strong>Path:</strong> /#{path.join('/')}
      <br /><br />
      <pre>#{@space.to_yaml}</pre>  
    HTML
  end
end
