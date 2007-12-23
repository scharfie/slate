# This file must exist to be a valid slate plugin
class ExampleSlatePlugin < Slate::Plugin
  routes do |map|
    map.resources :salutations, :path_prefix => 'spaces/:space_id'
  end
end