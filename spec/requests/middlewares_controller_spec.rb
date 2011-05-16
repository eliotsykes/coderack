require 'spec_helper'

describe MiddlewaresController do

  describe "#home" do
    
    it "should be successful" do
      3.times { Middleware.gen }
      [User.gen, nil].each do |user|
        login_as(user)
        get(root_path)
        response.should be_successful
      end
    end
    
  end
  
  describe "#index" do
    
    it "should be successful" do
      11.times { Middleware.gen.should be_valid }
      # page 1
      get(middlewares_path)
      response.should be_successful
      response.should_not have_selector("h2:contains('page')")
      # page 2
      get(middlewares_path, :page => 2)
      response.should be_successful
      response.should have_selector("h2:contains('page 2')")
    end
    
  end

  describe "#show" do

    it "should be successful" do
      middleware = Middleware.gen
      [User.gen, nil].each do |user|
        login_as(user)
        get(user_middleware_path(middleware.user, middleware))
        response.should be_successful
      end
    end

  end

  describe "#new" do

    it "should be successful for logged in user" do
      login_as(User.gen)
      get(new_middleware_path)
      response.should be_successful
    end
    
    it "should redirect to login page for guest user" do
      logout
      get(new_middleware_path)
      response.should redirect_to_login_page
    end
    
  end

  describe "#edit" do
    
    before(:all) do
      @middleware = Middleware.gen
    end

    it "should be successful for owner" do
      login_as(@middleware.user)
      get(edit_user_middleware_path(@middleware.user, @middleware))
      response.should be_successful
    end

    it "should be successful for admin" do
      admin = User.gen :admin => true
      login_as(admin)
      get(edit_user_middleware_path(@middleware.user, @middleware))
      response.should be_successful
    end
    
    it "should raise forbidden for non-owner" do
      login_as(User.gen)
      get(edit_user_middleware_path(@middleware.user, @middleware))
      response.should be_forbidden
    end
    
    it "should redirect to login page for guest user" do
      logout
      get(edit_middleware_path(@middleware))
      response.should redirect_to_login_page
    end
    
  end

  describe "#create" do
    
    it "should be successful for logged in user" do
      login_as(User.gen)
      attrs = Factory.attributes_for(:middleware)
      post(middlewares_path, :middleware => attrs)
      m = Middleware.order('id DESC').first
      response.should redirect_to(user_middleware_path(m.user, m))
    end
    
    it "should redirect to login page for guest user" do
      logout
      post(middlewares_path, :middleware => { :name => 'Misio' })
      response.should redirect_to_login_page
    end

    it "should not add entry for other user" do
      me = User.gen
      him = User.gen
      login_as(me)
      lambda {
        lambda {
          attrs = Factory.attributes_for(:middleware)
          attrs[:user_id] = him.id
          post(middlewares_path, :middleware => attrs)
          m = Middleware.order('id DESC').first
          response.should redirect_to(user_middleware_path(m.user, m))
        }.should_not change(him.middlewares, :count)
      }.should change(me.middlewares, :count).by(1)
    end
    
  end
  
  describe "#update" do
    
    before(:all) do
      @middleware = Middleware.gen
    end
    
    it "should be successful for owner" do
      login_as(@middleware.user)
      put(user_middleware_path(@middleware.user, @middleware), :middleware => { :name => 'changed' })
      response.should redirect_to(user_middleware_path(@middleware.user, @middleware.reload))
    end

    it "should be successful for admin" do
      admin = User.gen :admin => true
      login_as(admin)
      put(user_middleware_path(@middleware.user, @middleware), :middleware => { :name => 'changed' })
      response.should redirect_to(user_middleware_path(@middleware.user, @middleware.reload))
    end

    it "should raise forbidden for non-owner" do
      login_as(User.gen)
      put(user_middleware_path(@middleware.user, @middleware), :middleware => { :name => 'changed' })
      response.should be_forbidden
    end
    
    it "should redirect to login page for guest" do
      logout
      put(user_middleware_path(@middleware.user, @middleware), :middleware => { :name => 'changed' })
      response.should redirect_to_login_page
    end
    
    it "shouldn't change ownership" do
      login_as(@middleware.user)
      put(user_middleware_path(@middleware.user, @middleware),
        :middleware => { :name => 'changed', :user_id => User.gen.id })
      response.should redirect_to(user_middleware_path(@middleware.user, @middleware))
      Middleware.find_by_id(@middleware.id).user_id.should == @middleware.user.id
    end
    
  end
  
  describe "#destroy" do
    
    before :each do
      @middleware = Middleware.gen
    end
    
    it "should be successful for owner" do
      login_as(@middleware.user)
      delete(user_middleware_path(@middleware.user, @middleware))
      response.should redirect_to(user_path(@middleware.user))
    end

    it "should be successful for admin" do
      admin = User.gen :admin => true
      login_as(admin)
      delete(user_middleware_path(@middleware.user, @middleware))
      response.should redirect_to(user_path(@middleware.user))
    end

    it "should raise forbidden for non-owner" do
      login_as(User.gen)
      delete(user_middleware_path(@middleware.user, @middleware))
      response.should be_forbidden
    end
    
    it "should redirect to login page for guest" do
      logout
      delete(user_middleware_path(@middleware.user, @middleware))
      response.should redirect_to_login_page
    end

  end

  describe "#mine" do
    
    it "should redirect to login page for guest" do
      logout
      get(mine_middlewares_path)
      response.should redirect_to_login_page
    end
    
    it "should redirect to user's page for logged in user" do
      user = User.gen
      login_as(user)
      get(mine_middlewares_path)
      response.should redirect_to(user_path(user))
    end
    
  end

  describe "#vote" do

    before :each do
      @middleware = Middleware.gen
      @first_voter = Voter.gen
      @first_vote = @middleware.votes.create :voter => @first_voter, :score => 2.0
    end

    it "should be successful for middleware owner" do
      lambda {
        login_as(@middleware.user)
        cookies['voter_id'] = Voter.gen.id
        post(vote_middleware_path(@middleware), :score => 2)
        response.should be_successful
      }.should change(@middleware.votes, :count).by(1)
    end

    [
      ['other user', lambda { User.gen }],
      ['admin', lambda { User.gen(:admin => true) }],
      ['guest', lambda { nil }]
    ].each do |description, user|
      it "should be successful for #{description}" do
        lambda {
          login_as(user.call)
          cookies['voter_id'] = Voter.gen.id
          post(vote_middleware_path(@middleware), :score => 2)
          response.should be_successful
        }.should change(@middleware.votes, :count).by(1)
      end
    end

    context "when score parameter is blank" do
      it "should not create the vote if it doesn't exist yet" do
        lambda {
          login_as(User.gen)
          cookies['voter_id'] = Voter.gen.id
          post(vote_middleware_path(@middleware), :score => '')
          response.should be_successful
        }.should_not change(@middleware.votes, :count)
      end

      it "should not change the vote if it exists" do
        login_as(User.gen)
        cookies['voter_id'] = @first_voter.id
        post(vote_middleware_path(@middleware), :score => '')
        response.should be_successful

        @middleware.reload
        @middleware.votes.count.should == 1
        @middleware.votes.first.score.should == 2.0
      end
    end

    context "when score parameter is set" do
      it "should create the vote if it doesn't exist yet" do
        login_as(User.gen)
        cookies['voter_id'] = Voter.gen.id
        post(vote_middleware_path(@middleware), :score => 4.0)
        response.should be_successful

        @middleware.reload
        @middleware.votes.count.should == 2
        @middleware.votes.all.map(&:score).sort.should == [2.0, 4.0]
      end

      it "should change the vote if it exists" do
        login_as(User.gen)
        cookies['voter_id'] = @first_voter.id
        post(vote_middleware_path(@middleware), :score => 5.0)
        response.should be_successful

        @middleware.reload
        @middleware.votes.count.should == 1
        @middleware.votes.first.score.should == 5.0
      end
    end

  end

end
