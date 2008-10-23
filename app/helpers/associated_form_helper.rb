module AssociatedFormHelper
  # Builds a form for associated objects for the current resource
  # - the fields for the associated object should be defined by 
  # passing a block to this method (which yields a form builder object 
  # back to the block)
  def associated_form(*args, &block)
    options          = Hash === args.last ? args.pop : {}
    association_name = args.first
    resource         = options[:resource] || self.resource
    reflection       = resource.class.reflect_on_associated_save(association_name)
    from             = reflection.options[:from]
    association      = resource.send(association_name)
    locals           = {}

    locals[:sortable] = options.has_key?(:sortable) ? options[:sortable] : true
    locals[:association_name]   = association_name
    locals[:associated_objects] = options[:collection] || resource.associated_save_objects(association_name) || association.all
    
    locals[:label] = options[:label] || association_name.to_s.humanize
    locals[:path]  = path = options[:path] || "#{resource_name}[#{from}][]"
    
    locals[:form] = fields_for(path, association.new, :builder => Slate::FormBuilder) do |item|
      @associated_form_locals = locals
      capture(item, &block)
    end
    
    result = render(:partial => 'shared/associated_form', :locals => locals)
    concat result, block.binding
  end
end