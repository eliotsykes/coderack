class MiddlewaresController < ApplicationController

  before_filter :authenticate!, :only => [:new, :create, :edit, :update, :destroy, :mine]
  before_filter :load_middleware, :only => [:show, :edit, :update, :destroy, :vote]
  before_filter :ensure_owner_or_admin, :only => [:edit, :update, :destroy]
  before_filter :load_or_create_voter, :only => :vote
  before_filter :prepare_sort, :only => [:index, :search, :tagged]


  def index
    respond_to do |format|
      format.html do
        prepare_paginated_data(Middleware)
        @title = 'All middlewares'
        @header_title = 'Rack Middlewares'
      end
      format.xml do
        @middlewares = Middleware.sorted('date').limit(10).includes(:user, :tags)
      end
    end
  end

  def search
    keywords = params[:q].to_s.split(' ')
    prepare_paginated_data(Middleware.search(keywords))
    @title = 'Search entries'
    @header_title = "Search results for &lsquo;#{h(params[:q])}&rsquo;"
    
    render :index
  end

  def tagged
    @tag = Tag.find_by_name(params[:tag])

    if @tag
      prepare_paginated_data(@tag.middlewares)
    else
      prepare_paginated_data(Kaminari.paginate_array([]))
    end

    @title = @header_title = "Middlewares tagged with &lsquo;#{h(params[:tag])}&rsquo;"

    render :index
  end

  def show
    @title = @middleware.name
    voter = find_voter
    @users_score = voter && voter.score_for_middleware(@middleware)
  end

  def new
    @middleware = Middleware.new
  end

  def edit
  end

  def create
    @middleware = Middleware.new(params[:middleware])
    @middleware.user = current_user
    if @middleware.save
      flash[:notice] = "Your middleware has been successfully added to the list."
      redirect_to(user_middleware_path(@middleware.user, @middleware))
    else
      render :new
    end
  end

  def update
    if @middleware.update_attributes(params[:middleware])
      redirect_to(user_middleware_path(@middleware.user, @middleware), :notice => "Your middleware has been updated.")
    else
      render :edit
    end
  end

  def destroy
    author = @middleware.user
    if @middleware.destroy
      redirect_to(user_path(author), :notice => "Your middleware has been deleted.")
    else
      raise InternalServerError
    end
  end

  def vote
    vote = @middleware.votes.find_by_voter_id(@voter)
    score = params[:score].to_i
    if (1..5).include?(score)
      if vote
        vote.update_attributes :score => score
      else
        @middleware.votes.create :voter => @voter, :score => score
      end
    end
    head :ok
  end

  def mine
    redirect_to(user_path(current_user))
  end


  private

  def prepare_paginated_data(filter)
    filter = filter.sorted(@sort).includes(:user, :tags) if filter.respond_to?(:sorted)
    @page = pagination_page
    @middlewares = filter.page(@page)
    @total_middleware_count = @middlewares.total_count
    @offset = (@page - 1) * Middleware.default_per_page
  end

  def selected_menu_item
    :middlewares
  end

  def load_middleware
    @middleware = Middleware.find(params[:id].to_i)
  end

  def find_voter
    Voter.find_by_id(cookies[:voter_id]) if cookies[:voter_id]
  end

  def load_or_create_voter
    @voter = find_voter
    if @voter.nil?
      @voter = Voter.create :address => request.remote_ip
      cookies[:voter_id] = @voter.id
    end
  end

  def ensure_owner_or_admin
    raise Forbidden unless authenticated? && (current_user == @middleware.user || current_user.admin?)
  end

end
