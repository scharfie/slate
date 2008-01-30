class HelloController < Slate::Controller
  def index
  end
  
  def view_blog_article
    raise params.to_yaml
  end
end