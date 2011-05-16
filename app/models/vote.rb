class Vote < ActiveRecord::Base

  validates_presence_of :voter, :middleware, :score
  validates :score, :numericality => true, :inclusion => { :in => 1..5 }

  belongs_to :voter
  belongs_to :middleware

  after_save do
    self.middleware.update_average_score
  end

end
