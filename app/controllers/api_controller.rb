class ApiController < ApplicationController
  before_action { |controller| authorize! controller.action_name.to_sym, :api }

  def switch
    element, model = nil

    case params[:model].to_sym
      when :source
        model = Source
      when :cartridge
        model = Cartridge
      when :tender
        model = Tender
    end

    element = model.find(params[:id]) unless model.nil?

    unless element.nil?
      element.is_active = params[:active].to_sym == :on
      element.save
    end

    if model.nil? || element.nil?
      render :json => { result: "error: model or id not found" }
    else
      render :json => { result: "success"}
    end
  end

  def default_tender_values
    json = {}
    Tender.default_values_fields_list.each { |field| json[field] = Tender.human_attribute_name(field) }
    render :json => json
  end

  def selector_types
    json = []
    YAML.load_file('config/dictionaries/selector_types.yml').each { |type| json << type }
    render :json => json
  end

  def selector
    render :json => Selector.find(params[:id])
  end

  def check_code_source
    json = {}
    tender = Tender.where(source_id: params[:source_id], code_by_source: params[:code_by_source])
    json[:result] = tender.count > 0 ? tender.first._id.to_s : 0
    render :json => json
  end

  def statistic_day
    source = Source.find(params[:source])

    render :json => [
        source.name,
        12,
        123,
        434,
        123
    ]


  end

end