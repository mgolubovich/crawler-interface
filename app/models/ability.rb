class Ability
  include CanCan::Ability

  def initialize(user)

    @user = user || User.new # for guest

    DefaultController.action_methods.each { |action_method| can action_method.to_sym, :default }

    if @user.admin?
      ApiController.action_methods.each { |action_method| can action_method.to_sym, :api }
      SourcesController.action_methods.each { |action_method| can action_method.to_sym, :sources }
      CartridgesController.action_methods.each { |action_method| can action_method.to_sym, :cartridges }
      TendersController.action_methods.each { |action_method| can action_method.to_sym, :tenders }
      ModerationController.action_methods.each { |action_method| can action_method.to_sym, :moderation }

    elsif @user.editor?
      DefaultController.action_methods.each { |action_method| can action_method.to_sym, :default }
      ApiController.action_methods.each { |action_method| can action_method.to_sym, :api }
      SourcesController.action_methods.each { |action_method| can action_method.to_sym, :sources }
      CartridgesController.action_methods.each { |action_method| can action_method.to_sym, :cartridges }
      TendersController.action_methods.each { |action_method| can action_method.to_sym, :tenders }
      ModerationController.action_methods.each { |action_method| can action_method.to_sym, :moderation }

      cannot :destroy, :sources
      cannot :destroy, :cartridges
      cannot :destroy, :tenders

    elsif @user.moderator?
      ModerationController.action_methods.each { |action_method| can action_method.to_sym, :moderation }
    end
  end
end
