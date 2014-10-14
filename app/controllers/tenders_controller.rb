class TendersController < ApplicationController
  def index
    init_filter

    @tenders = Tender

    @filter.each do |filter, value|
      case filter
        when :date_start
          @tenders = @tenders.where(:created_at.gte => Time.parse(@filter[:date_start]).beginning_of_day) unless value.empty?
        when :date_end
          @tenders = @tenders.where(:created_at.lte => Time.parse(@filter[:date_end]).end_of_day) unless value.empty?
        when :created_by
           @tenders = @tenders.where(:created_by.in => [nil, value]) if value.to_sym == :parser
           @tenders = @tenders.where(created_by: value) if value.to_sym == :human
        else
          @tenders = @tenders.where(({filter => value})) unless value.empty?
      end
    end

    current_page = params[:page].to_i > 0 ? params[:page].to_i : 1
    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 50

    @total_count = @tenders.count
    @tenders = @tenders.page(current_page).per(per_page)
    @counter = (current_page - 1) * per_page
  end

  def create
    tender_attr = params["tender"].symbolize_keys
    tender = Tender.new
    tender.update_attributes! (tender_attr)
    redirect_to "/tenders/#{tender._id}/edit"
  end

  def new
    @tender = Tender.new
    @tender.source_id = params[:source_id] unless params[:source_id].to_s.empty?
    @sources = Source.all
    @regions = Region.all
    @cities = City.all
  end

  def edit
    @tender = Tender.find(params[:id])
    @sources = Source.all
    @regions = Region.all
    @cities = City.all
  end

  def show
    redirect_to "/tenders/#{params[:id]}/edit"
  end

  def update
    tender_attr = params["tender"].symbolize_keys
    tender = Tender.find(params[:id])
    tender.update_attributes! (tender_attr)

    redirect_to "/tenders/#{params[:id]}/edit"
  end

  def destroy
    tender = Tender.find(params[:id])
    tender.delete
    redirect_to action: :index
  end

  private

  def init_filter
    @filter = {
        date_start: "",
        date_end: "",
        code_by_source: "",
        created_by: "",
        source_id: ""
    }

    unless params[:source_id].to_s.empty?
      @filter[:source_id] = params[:source_id]
    end

    unless params[:filter].to_s.empty?
      params[:filter].symbolize_keys.each do |filter, value|
        @filter[filter] = value
      end
    end
  end
end
