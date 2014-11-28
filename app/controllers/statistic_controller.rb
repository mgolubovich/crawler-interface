class StatisticController < ApplicationController

  def index

  end

  def day
    @sources = { active: [], inactive: [] }
    Source.all.to_a.each do |source|
      active = source.is_active ? :active : :inactive
      @sources[active] << source
    end
  end

end