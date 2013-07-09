require 'spec_helper'

describe UsersController do
  
  describe "#show" do
    
    it "should be successful"
#U# do
#U#       user = User.gen
#U#       Middleware.gen(:user => user)
#U#       Middleware.gen(:user => user, :finalist => true)
#U#       get(user_path(user))
#U#       response.should be_successful
#U#       response.should have_selector("h2:contains('Rack middleware')")
#U#     end

    it "should render not_found" do
      get("/users/blah")
      response.should be_not_found
    end
    
  end

  describe "#new" do
    
    it "should be successful" do
      get(new_user_path)
      response.should be_successful
    end
    
  end

  describe "#create" do
    
    it "should create a user and redirect to the home page" do
      UsersController.any_instance.stubs(:session => { :identity_url => 'http://jan.mp' })
      lambda {
        post(users_path, :user => {
          :name => 'jan_kowalski', :email => 'jan@coderack.com', :identity_url => 'http://wrong.id'
        })
        response.should redirect_to(root_path)
      }.should change(User, :count).by(1)
      User.last.identity_url.should == 'http://jan.mp'
    end

    it "should ignore admin field" do
      UsersController.any_instance.stubs(:session => { :identity_url => 'http://zx.cv' })
      post(users_path, :user => { :name => 'asd', :email => 'asd@zx.cv', :admin => '1' })
      u = User.where(:email => 'asd@zx.cv').first
      u.email.should == 'asd@zx.cv'
      u.should_not be_an_admin
    end

  end

  describe "#edit" do

    before :each do
      @user = User.gen
    end

    it "should be successful for account owner" do
      login_as(@user)
      get(edit_user_path(@user))
      response.should be_successful
    end
    
    it "should raise forbidden for other user" do
      login_as(User.gen)
      get(edit_user_path(@user))
      response.should be_forbidden
    end
    
    it "should redirect to login page for guest" do
      logout
      get(edit_user_path(@user))
      response.should redirect_to_login_page
    end
    
  end

  describe "#update" do

    it "should be successful when changing only username" do
      user = User.gen
      login_as(user)
      put(user_path(user), :user => { :name => 'new_name', :email => user.email })
      response.should redirect_to(user_path(user.reload))
    end
    
    it "should be successful for account owner" do
      user = User.gen
      login_as(user)
      put(user_path(user), :user => { :name => 'new_name', :email => 'new@email.com' })
      response.should redirect_to(user_path(user.reload))
    end
    
    it "should raise forbidden for other user" do
      login_as(User.gen)
      put(user_path(User.gen), :user => { :name => 'new_name', :email => 'new@email.com' })
      response.should be_forbidden
    end
    
    it "should redirect to login page for guest" do
      logout
      put(user_path(User.gen), :user => { :name => 'new_name', :email => 'new@email.com' })
      response.should redirect_to_login_page
    end

    it "should use original username in form action url" do
      user = User.gen
      original_name = user.name
      login_as(user)
      put(user_path(user), :user => { :name => 'invalid name', :email => 'new@email.com' })
      response.should have_selector("form[action='/users/#{original_name}']")
    end

    it "should ignore admin field" do
      user = User.gen
      login_as(user)
      put(user_path(user), :user => { :admin => '1' })
      user.reload
      user.should_not be_an_admin
    end

  end

end
