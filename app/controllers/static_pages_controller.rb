class StaticPagesController < ApplicationController

  def home
  end

  def about
    @title = 'About'
  end

  def archive
    @sponsors = YAML.load(File.read(Rails.root.join('config', 'sponsors.yml')))
    @winners = Middleware.contest_winners.includes(:user, :tags)
    @honorable_mention = Middleware.honorable_mention.first
    @middlewares = Middleware.finalists.to_a.shuffle - @winners - [@honorable_mention]
    @total_middleware_count = Middleware.count
    @title = 'Archive'
  end


  private

  def selected_menu_item
    params[:action] == "home" ? :home : :about
  end

end
