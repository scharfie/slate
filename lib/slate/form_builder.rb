module Slate
  # Slate::FormBuilder is used to create forms in a consistent manner
  # It is based on the excellent TemplatedFormBuilder plugin
  # by Moritz Heidkamp (http://tpl-formbuilder.rubyforge.org/).
  # 
  # However, the following changes were made:
  #   - added support for a :tip argument
  #   - added actions helper which creates <div class="actions"></div>
  #     (used for submit tags)
  class FormBuilder < ActionView::Helpers::FormBuilder
    # creates a new form builder with default options
    def initialize(*args)
      super
      self.options.merge! :default_template => 'element', :label_append => ''
    end
        
    # redefine the field helpers 
    (field_helpers + %w(date_select datetime_select collection_select select)).each do |helper|
      define_method(helper) do |*args|
        args << Hash.new unless Hash === args.last

        label = args[-1].delete(:label) { args.first.to_s.humanize }
        tip   = args[-1].delete(:tip)

        template = nil
        if args[-1].has_key?(:template)
          template = args[-1].delete(:template)
          return super(*args) unless template
        end

        render_form_element helper, label, tip, template, args, super(*args)
      end
    end

  private
    # renders the form element using partials from forms/
    def render_form_element(helper, label, tip, template, helper_args, element)
      locals = {
        :label => label_for(helper_args.first, label),
        :element => element,
        :tip => tip,
        :errors => @template.error_message_on("#{@object_name}","#{helper_args[0]}", helper_args[0].to_s.humanize + ' ')
      }

      begin
        @template.render :partial => "forms/#{template || helper}", :locals => locals
      rescue ActionView::ActionViewError
        @template.render :partial => "forms/#{self.options[:default_template] || 'element'}", :locals => locals
      end
    end

  public
    # generates a label element for given method of 
    # current object, using the given label for text
    def label_for(method, label)
      return '' if label.nil?
      label += (self.options[:label_append] || '') unless label =~ /\?$/
      @template.content_tag('label', label, {:for => "#{@object_name}_#{method}"})
    end
    
    # surrounds the given block in a DIV with class 'actions'
    def actions(&block)
      @template.concat '<div class="actions">' + 
        @template.capture(&block) +
      '</div>', block.binding
    end
  end
end