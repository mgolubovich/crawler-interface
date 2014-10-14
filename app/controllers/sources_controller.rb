class SourcesController < ApplicationController

  #method GET. Display a list of all sources
  def index
    init_filter

    current_page = params[:page].to_i > 0 ? params[:page].to_i : 1
    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 50

    @sources = Source

    if @filter.count > 0
      unless @filter[:type].to_s.empty?
        @sources = @sources.where(:source_type.in => [:auto, nil]) if @filter[:type].to_sym == :auto
        @sources = @sources.where(source_type: :manual) if @filter[:type].to_sym == :manual
      end

      unless @filter[:search].to_s.empty?
        regexp = Regexp.new(@filter[:search], Regexp::IGNORECASE)
        @sources = @sources.or({name: regexp}, {url: regexp})
      end
    end

    @total_sources_count = @sources.count
    @sources = @sources.page(current_page).per(per_page)
    @counter = (current_page - 1) * per_page
  end

  #method POST. Create a new source
  def create
    source = Source.new
    source_attrib = params[:source].symbolize_keys
    source_attrib[:proxy_update_frequency].symbolize_keys!
    source_attrib[:trigger]["after"] = source_attrib[:trigger]["after"].to_i > 0
    source_attrib[:trigger]["before"] = source_attrib[:trigger]["before"].to_i > 0
    source_attrib[:is_active] = source_attrib[:is_active].to_i > 0
    source.update_attributes!(source_attrib)

    redirect_to :action => :index
  end

  #method GET. Return an HTML form for creating a new source
  def new
    @source = Source.new
    @priorities = {}
    YAML.load_file('config/dictionaries/resque_priorities.yml').symbolize_keys!.each do |priority, params|
      @priorities[priority] = params["name"] if params["type"].to_sym == :auto
    end
  end

  #method GET. Return an HTML form for editing a source
  def edit
    @source = Source.find(params[:id])
    @priorities = {}
    YAML.load_file('config/dictionaries/resque_priorities.yml').symbolize_keys!.each do |priority, params|
      @priorities[priority] = params["name"] if params["type"].to_sym == :auto
    end
  end

  #method GET. Display a specific source
  def show
    redirect_to "/sources/#{params[:id]}/edit"
  end

  #methods PATCH/PUT. Update a specific source
  def update
    source = Source.find(params[:id])
    if source
      source_attrib = params[:source].symbolize_keys
      source_attrib[:proxy_update_frequency].symbolize_keys!
      source_attrib[:trigger]["after"] = source_attrib[:trigger]["after"].to_i > 0
      source_attrib[:trigger]["before"] = source_attrib[:trigger]["before"].to_i > 0
      source_attrib[:is_active] = source_attrib[:is_active].to_i > 0
      source.update_attributes!(source_attrib)
    end
    redirect_to :action => :index
  end

  #method DELETE. Delete a specific source
  def destroy
    source = Source.find(params[:id])
    source.delete unless source.nil?
    redirect_to :action => :index
  end

  private

  def init_filter
    @filter = { type: :all, search: "" }
    unless params[:filter].nil?
      params[:filter].each do |filter, value|
        @filter[filter.to_sym] = value unless value.to_s.empty?
      end
    end

    @filter
  end

end
