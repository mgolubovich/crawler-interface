class Ability
  include CanCan::Ability

  def initialize(user)

    @user = user || User.new # for guest

    if @user.admin?
      DefaultController.action_methods.each { |action_method| can action_method.to_sym, :default }
      ApiController.action_methods.each { |action_method| can action_method.to_sym, :api }
      SourcesController.action_methods.each { |action_method| can action_method.to_sym, :sources }
      CartridgesController.action_methods.each { |action_method| can action_method.to_sym, :cartridges }
      TendersController.action_methods.each { |action_method| can action_method.to_sym, :tenders }

    elsif @user.editor?
      DefaultController.action_methods.each { |action_method| can action_method.to_sym, :default }
      ApiController.action_methods.each { |action_method| can action_method.to_sym, :api }
      SourcesController.action_methods.each { |action_method| can action_method.to_sym, :sources }
      CartridgesController.action_methods.each { |action_method| can action_method.to_sym, :cartridges }
      TendersController.action_methods.each { |action_method| can action_method.to_sym, :tenders }

    elsif @user.moderator?
      DefaultController.action_methods.each { |action_method| can action_method.to_sym, :default }
      cannot :index, :cartridges
    end
  end
end
