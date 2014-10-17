class ModerationController < ApplicationController

  before_action { |controller| authorize! controller.action_name.to_sym, :moderation }

  class << self
    attr_accessor :external_work_types
  end

  @external_work_types = YAML.load_file('config/dictionaries/tender_external_work_types.yml')

  def next
    params = {
        external_work_type: -1,
        :lock.ne => false,
        :start_at.gte => Time.now.at_beginning_of_day,
        moderated_by: nil
    }

    @tender = Tender.where(params)
      .not_in(title: ["", nil])
      .order_by(created_at: :asc)
      .first

    if @tender.nil?
      @message = "Нет тендеров для модерации."
      render "for_message"
    else
      @tender.update_attributes!(lock: true, moderated_at: Time.now, moderated_by: current_user._id)
    end
  end

  def prev
    @tender = Tender.order_by(moderated_at: :asc)

    @tender = @tenders.where(moderated_by: current_user._id) unless current_user.admin?
    @tender = params[:id].nil? ? @tender.skip(1).last : @tender.where(_id: params[:id]).last

    if @tender.nil?
      @message = "Тендеры еще не модерировались или тендер не найден."
      render "for_message"
    end

  end

  def list
    @marks = {
        :check => {icon: "check", color: :green},
        :skip  => {icon: "prohibited", color: :orange},
        :alert => {icon: "alert", color: :red},
    }

    @tenders = Tender.where(
        :moderated_at.gte => Time.now.at_beginning_of_day,
        :moderated_at.lte => Time.now.at_end_of_day
    ).order_by(external_work_type: :asc, moderated_at: :asc)

    @tenders = @tenders.where(moderated_by: current_user._id) unless current_user.admin?

    current_page = params[:page].to_i > 0 ? params[:page].to_i : 1
    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 100

    @tenders = @tenders.page(current_page).per(per_page)

    @moderated_tenders = moderated_tenders
    @actual_tenders = actual_tenders
    @skip_tenders = skip_tenders

    @users = {}
    User.all.each { |user| @users[user._id.to_s] = user.email }
  end

  def moderate
    @tender = Tender.where(_id: params[:id]).first
    @tender = @tenders.where(moderated_by: current_user._id) unless current_user.admin?

    if @tender.nil?
      @message = "Тендер не найден."
      render "for_message"
    else
      @tender.update_attributes!(lock: false, moderated_at: Time.now, external_work_type: params[:type])

      url = "/moderation/"
      url += "#{params[:back]}/" unless params[:back].to_s.empty?

      redirect_to url
    end
  end

  private

  def moderated_tenders
    params = {
        :external_work_type.gte => 0,
        :moderated_at.gte => Time.now.at_beginning_of_day
    }

    params[:moderated_by] = current_user._id unless current_user.admin?

    Tender.where(params).count
  end

  def actual_tenders
    params = {
        :external_work_type => -1,
        :start_at.gte => Time.now.at_beginning_of_day,
        :lock.ne => false,
        moderated_by: nil
    }

    Tender.where(params).count
  end

  def skip_tenders
    params = {
        :external_work_type.gte => -1,
        :moderated_at.gte => Time.now.at_beginning_of_day,
        :lock => true
    }

    params[:moderated_by] = current_user._id unless current_user.admin?

    Tender.where(params).count
  end


end