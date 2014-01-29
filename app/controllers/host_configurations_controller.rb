class HostConfigurationsController < ApplicationController

  before_filter :load_host
  before_filter :ensure_admin, :only => [:new, :edit, :destroy, :create, :update]

  # GET /hosts/1/host_configurations/1
  # GET /hosts/1/host_configurations/1.xml
  def show
    @configuration = current_host.configuration_parameters.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @configuration.to_xml }
    end
  end

  # GET /hosts/1/host_configurations/new
  def new
    @configuration = current_host.configuration_parameters.new
  end

  # GET /hosts/1/host_configurations/1;edit
  def edit
    @configuration = current_host.configuration_parameters.find(params[:id])
  end

  # POST /hosts/1/host_configurations
  # POST /hosts/1/host_configurations.xml
  def create
    @configuration = current_host.configuration_parameters.build(params[:configuration])

    respond_to do |format|
      if @configuration.save
        flash[:notice] = 'hostConfiguration was successfully created.'
        format.html { redirect_to host_url(current_host) }
        format.xml  { head :created, :location => host_url(current_host) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @host_configuration.errors.to_xml }
      end
    end
  end

  # PUT /hosts/1/host_configurations/1
  # PUT /hosts/1/host_configurations/1.xml
  def update
    @configuration = current_host.configuration_parameters.find(params[:id])

    respond_to do |format|
      if @configuration.update_attributes(params[:configuration])
        flash[:notice] = 'hostConfiguration was successfully updated.'
        format.html { redirect_to host_url(current_host) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @configuration.errors.to_xml }
      end
    end
  end

  # DELETE /hosts/1/host_configurations/1
  # DELETE /hosts/1/host_configurations/1.xml
  def destroy
    @configuration = current_host.configuration_parameters.find(params[:id])
    @configuration.destroy

    respond_to do |format|
      flash[:notice] = 'hostConfiguration was successfully deleted.'
      format.html { redirect_to host_url(current_host) }
      format.xml  { head :ok }
    end
  end
end
