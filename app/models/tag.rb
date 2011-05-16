class Tag < ActiveRecord::Base

  validates :name, :presence => true, :uniqueness => true, :length => { :minimum => 2, :maximum => 30 }
  has_and_belongs_to_many :middlewares

end
