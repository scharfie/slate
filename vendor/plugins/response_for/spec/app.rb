class FooController < ApplicationController
  def foo
    @foo = "Foo"
    respond_to do |format|
      format.html {}
    end
  end
  
  # testing that erase_render_results works as expected
  def bar
    respond_to(:json)
    erase_render_results
  end
  
  def baz
    # no respond_to block in here, but we can still supplu one with response_for
  end
end

class XmlFooController < FooController
  response_for :just_a_template, :foo, :bar, :types => [:xml]
end

class FooBailOutController < FooController
  before_filter :bail_out
  
  response_for :foo do |format|
    format.html { render :action => 'foo'}
  end
  
protected
  def bail_out
    if params[:bail_out]
      respond_to do |format|
        format.html { redirect_to 'http://test.host/redirected' }
      end
    end
  end
end

class InlineXmlFooController < FooController
  response_for :foo do |format|
    format.xml do
      render :inline => xml_call(action_name) # to be stubbed in specs
    end
  end
end

class XmlOnlyFooController < FooController
  response_for :foo, :bar, :types => [:xml], :replace => true
end

class BackToFooController < XmlFooController
  remove_response_for :foo, :bar
end