class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_filter :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    @name = "Forbidden"
    @message = "Недостаточно прав"
    @status = 403


    render layout: "error", template: 'default/error', status: 403
  end
end
