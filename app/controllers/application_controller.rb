class ApplicationController < ActionController::Base

  class GenericException < StandardError ; end
  class Forbidden < GenericException ; end
  class NotFound < GenericException ; end

  rescue_from GenericException, :with => :handle_exception

  protect_from_forgery
  layout 'application'

  helper_method :selected_menu_item, :authenticated?, :current_user


  private

  delegate :authenticated?, :authenticate!, :to => :warden

  def warden
    env['warden']
  end

  def current_user
    warden.user
  end

  def handle_exception(e)
    filename = e.class.name.split(/::/).last.underscore
    render :template => "exceptions/#{filename}", :status => filename.to_sym
  end

  def selected_menu_item
    :home
  end

  def prepare_sort
    @sort = (params[:sort] == 'score') ? 'score' : 'date'
  end

  def pagination_page
    [params[:page].to_i, 1].max
  end

end
