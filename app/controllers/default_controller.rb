class DefaultController < ApplicationController
  def index

  end

  def error
    render layout: "authorization"
  end
end