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
  end
end