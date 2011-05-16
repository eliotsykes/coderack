class UsersController < ApplicationController

  before_filter :authenticate!, :except => [:show, :new, :create, :login]
  before_filter :load_user, :only => [:show, :edit, :update]
  before_filter :ensure_can_edit, :only => [:edit, :update]
  before_filter :prepare_sort, :only => :show

  def show
    @middlewares = @user.middlewares.includes(:user, :tags).sorted(@sort)
    @title = "#{h(@user.name)}'s middlewares"
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(params[:user])
    @user.identity_url = session[:identity_url]
    if @user.save
      session.delete(:identity_url)
      warden.set_user(@user)
      redirect_to(root_path, :notice => "Signup was successful. Now submit your code!")
    else
      render :new
    end
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to(user_path(@user), :notice => "Your account settings have been updated.")
    else
      render :edit
    end
  end

  def login
    if request.post?
      warden.authenticate!
      redirect_to(root_path, :notice => "You are now in.")
    end
  end

  def logout
    warden.logout
    redirect_to(root_path, :notice => "You have been signed out. But you will come back, right?")
  end


  private

  def selected_menu_item
    :middlewares
  end

  def load_user
    @user = User.find_by_name(params[:id].to_s.strip) or raise NotFound
  end

  def ensure_can_edit
    raise Forbidden unless @user == current_user || current_user.admin?
  end

end
