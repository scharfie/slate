module Ardes #:nodoc:
  module ResponseFor
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        alias_method_chain :run_before_filters, :response_for
        alias_method_chain :respond_to, :response_for
        alias_method_chain :render, :response_for
        alias_method_chain :erase_render_results, :response_for
      end
    end
    
    module ClassMethods
      # response_for allows you to decorate your actions with small respond_to
      # chunks.
      # 
      # One use for this is with subclassed controllers, so you don't have to rewrite the entire action.
      # 
      #
      # === Example
      #
      #   class FooController < ApplicationController
      #     def index
      #       @foos = Foo.find(:all)
      #     end
      #   
      #     def show
      #       @foo = Foo.find(params[:id])
      #     end
      #   end
      #   
      #   # this controller needs to respond_to fbml on index, and
      #   # js, html and xml (templates) on index and show
      #   class SpecialFooController < FooController
      #     response_for :index do |format|
      #       format.fbml { render :inline => turn_into_facebook(@foos) }
      #     end
      #   
      #     response_for :index, :show, :types => [:html, :xml, :js]
      #   end
      #
      # === Important
      # If you want to make sure that no repsonse_for can override your repsond_to
      # block, then use respond_to_without_response_for
      #
      # An example of this would be when you want to redirect on html in a 
      # before_filterl, and you definitely don't want response_for to override that
      # 
      # === Usage
      #
      #   response_for :action1 [, :action2], [,:types => [:mime, :type, :list]] [,:replace => <boolean>] [ do |format| ... end]
      #
      # For example:
      #
      #   response_for :index, :types => [:fbml]    # index will respond to fbml and try to render, say, index.fbml.builder
      #
      #   response_for :update do |format|          # this example is for a resources_controller controller
      #     if resource.valid?
      #       format.js { render(:update) {|page| page.replace(dom_id(resource), :partial => resource}}
      #     else
      #       format.js { render(:update) {|page| page.visual_effect :shake, dom_id(resource) }}
      #     end
      #   end
      #
      #   response_for :index, :replace => true do |format|   # will ignore index's current respond_to block, and use the following
      #     format.xml
      #     format.js
      #   end
      #
      # === Notes
      #
      # * You don't need to have a respond_to block in the action for response_for to work
      # * You can stack up multiple response_for calls, the most recent has precedence
      # * the specifed block is executed within the controller instance, so you can use controller
      #   instance methods are instance variables (i.e. you can make it look just like a regular
      #   respond_to block)
      # * you can add a response_for an action that is just a public template (where there is no
      #   actual action method defined)
      # * you can combine the :types option with a block, the block has precedence if you specify the
      #   same mime type in both.
      def response_for(*actions, &block)
        options = actions.extract_options!
        options.assert_valid_keys(:replace, :types)
        
        types = (options[:types] && proc{|r| options[:types].each {|t| r.send(t)}}) || nil
        
        actions.collect(&:to_s).each do |action|
          if options[:replace]
            action_responses[action] = []
            respond_to_replaced[action] = true
          else
            action_responses[action] ||= []
          end
          action_responses[action] << types if types
          action_responses[action] << block if block_given?
        end
      end
      
      # Removes any response_for for the supplied action names.
      # This will not remove any respond_to block that is defined in the action itself
      def remove_response_for(*actions)
        actions.collect(&:to_s).each {|action| respond_to_replaced[action] = action_responses[action] = nil}
      end
    
    protected
      # return action_responses Hash. On initialize, return a hash whose contents are duplicates
      # of the superclass's action_responses.
      def action_responses
        instance_variable_get('@action_responses') or
          instance_variable_set('@action_responses', (superclass.action_responses.inject({}) {|m,(k,v)| m.merge(k => v.dup)} rescue {}))
      end
      
      # hash of actions where the respond_to blcok has been replaced
      def respond_to_replaced
        read_inheritable_attribute(:respond_to_replaced) || write_inheritable_attribute(:respond_to_replaced, {})
      end
    end
  
  protected
    # we only want response_for to trigger once we've got to the performing action stage
    # otherwise respond_to in before filters will act unpredictably
    def run_before_filters_with_response_for(*args)
      @running_before_filters = true
      run_before_filters_without_response_for(*args)
    ensure
      @running_before_filters = nil
    end
    
    # if you want to ignore any response_for blocks, and gain exclusive respond_to
    # control, pass :exclusive => true
    #
    #   respond_to :exclusive => true do |format|
    #
    # But, also see ClassMethods#remove_response_for
    def respond_to_with_response_for(*types, &block)
      options = types.extract_options!
      return respond_to_without_response_for(*types, &block) if options[:exclusive] || @running_before_filters
      
      respond_to_without_response_for do |responder|
        if action_blocks = self.class.send(:action_responses)[action_name]
          action_blocks.reverse.each {|b| instance_exec(responder, &b)}
        end
        unless self.class.send(:respond_to_replaced)[action_name]
          types.each {|type| responder.send(type)}
          block.call(responder) if block
        end
      end
    ensure
      @performed_respond_to = true
    end
    
    # removes the @performed_respond_to along with the standard erase_render_results call
    def erase_render_results_with_response_for
      @performed_respond_to = false
      erase_render_results_without_response_for
    end
    
    # Adds a hook for when render is called without arguments or a block.
    # Prior to rendering, call respond_to if there is a response_for, and 
    # if respond_to has not yet been performed.
    #
    # This allows actions without an explicit respond_to block to be decorated
    # with response_for
    def render_with_response_for(*args, &block)
      if !instance_variable_get('@performed_respond_to') && self.class.send(:action_responses)[action_name] && !block_given? && args.reject{|a| a.nil? || a.empty?}.empty?
        respond_to
        return if performed?
      end
      render_without_response_for(*args, &block)
    end
  end
end