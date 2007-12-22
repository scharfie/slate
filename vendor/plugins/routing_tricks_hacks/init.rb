ActionController::Routing::Route.class_eval do
  # hacked to support not_host, not_domain, and not_subdomain
  # Note that we are overriding recognition_conditions because
  # the routing_tricks plugin has already performed an alias 
  # method chain.  Simply overriding recognition_conditions_with_host
  # would not work.
  def recognition_conditions
    result = recognition_conditions_without_host
    
    [:host, :domain, :subdomain].each do |condition|
      result << "conditions[:#{condition}]     === env[:#{condition}]" if conditions[condition]
      result << "conditions[:not_#{condition}] !=  env[:#{condition}]" if conditions["not_#{condition}".to_sym]
    end
    
    result
  end
end