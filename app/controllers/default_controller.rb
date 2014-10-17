class DefaultController < ApplicationController
  before_action { |controller| authorize! controller.action_name.to_sym, :default }

  def index

  end

  def error
    render layout: "authorization"
  end
end