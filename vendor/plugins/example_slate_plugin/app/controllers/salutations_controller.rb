class SalutationsController < Slate::Controller
  resources_controller_for :salutations, :in => :space, 
    :only => [:index]

public
  def index
  end
end