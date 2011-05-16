require 'spec_helper'

describe User do
  describe 'creation' do

    it "should not be an admin" do
      User.prepare.should_not be_an_admin
    end

    it 'should be valid with username, email and identity_url' do
      User.prepare(:identity_url => 'http://janko.mp').valid?.should be(true)
    end

    it 'should not be valid without identity_url' do
      User.prepare(:identity_url => nil).valid?.should be(false)
    end

    it "should validate username format" do
      %w(jola jola81 81jola mi-sio mi_sio why).each do |name|
        User.prepare(:name => name).should be_valid
      end
      %w(jola: jo,la jo$ jo#la @jola foo+bar why? why! ab a hax<b>X</b>0r jo.la).each do |name|
        User.prepare(:name => name).should_not be_valid
      end
    end
    
    it "should validate username length" do
      User.prepare(:name => 'a').should_not be_valid
      User.prepare(:name => 'ab').should_not be_valid
      User.prepare(:name => 'abc').should be_valid
      User.prepare(:name => 'a' * 30).should be_valid
      User.prepare(:name => 'a' * 31).should_not be_valid
    end
    
    it 'should not be valid with duplicated properties' do
      existing = User.gen
      user = User.prepare(:name => existing.name, :email => existing.email, :identity_url => existing.identity_url)
      user.valid?.should be(false)
      user.errors[:name].should_not be_nil
      user.errors[:email].should_not be_nil
      user.errors[:identity_url].should_not be_nil
    end

    it 'should not be valid with an invalid email' do
      user = User.prepare(:email => 'jan@')
      user.valid?.should be(false)
      user.errors[:email].should_not be_nil
    end

    it 'should allow long identity_url' do
      User.prepare(:identity_url => 'https://me.yahoo.com/a/KiUcaNkcjdOtaXEuoLMS7Oe1s9MqPS8-#bd5ef').valid?.should be(true)
    end

  end

  describe "#to_param" do
    it "should appear as username in URLs" do
      user = User.gen :name => 'bob'
      user.to_param.should == 'bob'
    end

    it "should keep old username in URLs if it's changed (until user is saved)" do
      user = User.gen :name => 'bob'
      user.name = 'mike'
      user.to_param.should == 'bob'
      user.save
      user.to_param.should == 'mike'
    end
  end

  it "should not let user become an admin by hacking a form" do
    u = User.gen
    u.update_attributes :admin => true
    u.reload.should_not be_an_admin

    u.admin = true
    u.save
    u.reload.should be_an_admin
  end

  it "should not let user change his identity url by hacking a form" do
    u = User.gen
    u.update_attributes :identity_url => "http://google.com"
    u.reload.identity_url.should_not == "http://google.com"

    u.identity_url = "http://google.com"
    u.save
    u.reload.identity_url.should == "http://google.com"
  end

end
