module Slate
  module ResourcesController
    module Actions
      # Include the default actions
      include Ardes::ResourcesController::Actions

      # # GET /events/new
      # def new
      #   self.resource = resource_service.find_by_id(params[:id]) || new_resource
      #   def resource.new_record?() true end
      # 
      #   respond_to do |format|
      #     format.html # new.html.erb
      #     format.js
      #     format.xml  { render :xml => resource }
      #   end
      # end

      # POST /events
      # POST /events.xml
      def create
        self.resource = new_resource

        respond_to do |format|
          if resource_saved?
            format.html do
              flash[:notice] = "#{resource_name.humanize} was successfully created."
              # redirect_to resource_url
              if params[:commit] =~ /continue/i
                redirect_to edit_resource_url
              else
                redirect_to resource_url
              end
            end
            format.js
            format.xml  { render :xml => resource, :status => :created, :location => resource_url }
          else
            format.html { render :action => "new" }
            format.js   { render :action => "new" }
            format.xml  { render :xml => resource.errors, :status => :unprocessable_entity }
          end
        end
      end

      # PUT /events/1
      # PUT /events/1.xml
      def update
        self.resource = find_resource
        resource.attributes = params[resource_name]

        respond_to do |format|
          if resource_saved?
            format.html do
              flash[:notice] = "#{resource_name.humanize} was successfully updated."
              # redirect_to resource_url
              if params[:commit] =~ /continue/i
                redirect_to edit_resource_url
              else
                redirect_to resource_url
              end          
            end
            format.js
            format.xml  { head :ok }
          else
            format.html { render :action => "edit" }
            format.js   { render :action => "edit" }
            format.xml  { render :xml => resource.errors, :status => :unprocessable_entity }
          end
        end
      end  
    end
  end
end    