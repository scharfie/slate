# This file must exist to be a valid slate plugin
class ExampleSlatePlugin < Slate::Plugin
  navigation do |tabs|
    tabs.add 'Salutations'
    tabs.add 'Hello', :match => :exact, :url => hello_path
  end
  
  routes do |map|
    map.with_space do |space|
      space.resources :salutations
    end
    
    map.hello 'hello', :controller => 'hello'
    
    map.public_routes do |m| 
      m.connect '*page_path/:year/:month/:day/:permalink',
        :month => nil, :day => nil, :permalink => nil,
        :controller => 'hello', :action => 'view_blog_article',
        :requirements => { 
          :year => /\d{4}/
        }
    end  
  end
end