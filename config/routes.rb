require 'slate/routing'

ActionController::Routing::Routes.draw do |map|
  # Load plugin route definitions
  Slate.plugins.each do |plugin|
    plugin.route_definitions.each { |block| block.call(map) }
  end

  # public side
  # map all requests that do not have slate as the subdomain to
  # the public controller and group all parameters in page_path
  map.public_routes do |m|
    # support "peridocal" routes
    m.connect '*page_path/:year/:month/:day/:slug',
      :month => nil, :day => nil, :slug => nil,
      :requirements => { 
        :year => /\d{4}/, 
        :month => /\d{1,2}|/, 
        :day => /\d{1,2}|/ 
      }
    
    # catch normal page routes
    m.connect '*page_path'
  end

  map.default '', :controller => 'account', :action => 'login', 
    :erp => '/account/login'

  map.connect 'stylesheets/:action.:format', :controller => 'stylesheets'
  
  # ==========================================
  # mappings for accounts
  # ==========================================
  map.resource :account, :controller => 'account', 
    :member => { :login => :any, :logout => :get }
  
  map.with_options :controller => 'account' do |m|
    m.login 'login', :action => 'login', :erp => '/account/login'
    m.logout 'logout', :action => 'logout', :erp => '/account/logout'
  end

  map.resources :users

  # ==========================================
  # mappings for spaces
  # ==========================================
  map.resources :spaces, :collection => { :choose => :post } do |space|
    space.resource :dashboard, :controller => 'dashboard',
      :name_prefix => 'space_'
    space.resources :pages, :collection => {
      :organize => :get,
      :remap => :put
    } do |page|
      page.resources :areas, :member => { 
        :toggle => :any, 
        :preview => :post,
        :version => :get
      }
    end
    
    space.resources :assets, :member => {
      :extract => :get
    }
  end
  
  # custom route for new page which allows an id to be
  # passed in - this is considered the parent id
  map.new_space_page 'spaces/:space_id/pages/new/:id', 
    :controller => 'pages', :action => 'new'
  
  map.resource :dashboard, :controller => 'dashboard'
  
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end