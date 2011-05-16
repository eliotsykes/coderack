class User < ActiveRecord::Base

  EMAIL_FORMAT = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/

  validates_presence_of :name, :email, :identity_url
  validates_uniqueness_of :name, :email, :identity_url
  validates :name, :length => { :minimum => 3, :maximum => 30 },
    :format => { :with => /^[\w\-]+$/ }, :allow_blank => true
  validates :email, :length => { :maximum => 255 }, :format => { :with => EMAIL_FORMAT }, :allow_blank => true
  validates :identity_url, :length => { :maximum => 255 }
  validates :github_username, :length => { :maximum => 50 }, :format => /^[\w\-\.]+$/, :allow_blank => true
  validates :twitter_username, :length => { :maximum => 50 }, :format => /^[\w\-\.]+$/, :allow_blank => true

  attr_protected :admin, :identity_url

  has_many :middlewares
  
  def password_required?
    self.identity_url.blank?
  end

  def to_param
    name_was
  end

end
