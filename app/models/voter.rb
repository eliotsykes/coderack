class Voter < ActiveRecord::Base

  validates :address, :presence => true, :format => { :with => /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/ }
  has_many :votes

  def score_for_middleware(middleware)
    self.votes.find_by_middleware_id(middleware).try(:score)
  end

end
