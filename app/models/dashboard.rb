class Dashboard < ActiveRecord::Base
  # This model exists solely for making resources_controller
  # work with the Dashboard controller
  self.abstract_class = true
end