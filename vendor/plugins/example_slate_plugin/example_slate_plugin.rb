# This file must exist to be a valid slate plugin
class ExampleSlatePlugin < Slate::Plugin
  routes do |map|
    map.with_space do |space|
      space.resources :salutations
    end
  end
end