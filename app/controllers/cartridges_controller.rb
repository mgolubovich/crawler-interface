class CartridgesController < ApplicationController
  before_action { |controller| authorize! controller.action_name.to_sym, :cartridges }

  def index
    @cartridges = Cartridge
    @cartridges = @cartridges.where(source_id: params[:source_id]) unless params[:source_id].to_s.empty?

    current_page = params[:page].to_i > 0 ? params[:page].to_i : 1
    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 50

    @total_count = @cartridges.count
    @cartridges = @cartridges.page(current_page).per(per_page)
    @counter = (current_page - 1) * per_page
  end

  def create
    page_manager = PageManager.new
    page_manager.update_attributes!(params[:page_manager].symbolize_keys)

    cartridge = Cartridge.new
    cartridge_params = params[:cartridge].symbolize_keys
    cartridge_params[:is_active] = cartridge_params[:is_active].to_i == 1
    cartridge.update_attributes!(cartridge_params)

    cartridge.page_managers << page_manager
    cartridge.save

    params[:selectors].each do |id, selector_attr|
        selector_attr[:cartridge_id] = cartridge._id
        selector = Selector.new
        selector.update_attributes!(selector_attr.symbolize_keys)
    end

    redirect_to "/cartridges/#{cartridge._id}/edit"
  end

  def new
    @cartridge = Cartridge.new
    @page_manager = PageManager.new
    @sources = Source.all.to_a
    @cartridge.source_id = params[:source_id] unless params[:source_id].to_s.empty?
  end

  def edit
    @cartridge = Cartridge.find(params[:id])
    @page_manager = @cartridge.page_managers.first
    @selectors = @cartridge.selectors.order_by(:priority.asc)
    @sources = Source.all.to_a
  end

  def show
    redirect_to "/cartridges/#{params[:id]}/edit"
  end

  def update
    cartridge = Cartridge.find(params[:id])
    cartridge_params = params[:cartridge].symbolize_keys
    cartridge_params[:is_active] = cartridge_params[:is_active].to_i == 1
    cartridge.update_attributes!(cartridge_params)

    page_manager = cartridge.page_managers.first
    page_manager.update_attributes!(params[:page_manager].symbolize_keys)

    saved_selectors = []

    cartridge.selectors.each do |selector|
      unless params[:selectors][selector._id.to_s].nil?
        selector_params = params[:selectors][selector._id.to_s].symbolize_keys
        selector_params[:cartridge_id] = cartridge._id
        selector.update_attributes!(selector_params)
        saved_selectors << selector._id.to_s
      else
        selector.delete
      end
    end

    params[:selectors].each do |id, selector_params|
      unless id.index("new").nil?
        selector_params = selector_params.symbolize_keys
        selector_params[:cartridge_id] = cartridge._id

        selector = Selector.new
        selector.update_attributes!(selector_params)
      end
    end

    redirect_to "/cartridges/#{cartridge._id}/edit"
  end

  def destroy
    Cartridge.find(params[:id]).delete
    redirect_to "/cartridges/"
  end

  private
end
