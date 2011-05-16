require 'spec_helper'

describe Vote do

  it "should validate score" do
    (1..5).each do |score|
      v = Vote.new(:score => score)
      v.valid?
      v.errors[:score].should be_empty
    end

    ["-1", "6", "100"].each do |score|
      v = Vote.new(:score => score)
      v.valid?
      v.errors[:score].should_not be_empty
    end
  end

  it "should update cached average_score in its middleware when created" do
    m = Middleware.gen
    m.votes.create :voter => Voter.gen, :score => 2.0
    m.reload.average_score.should == 2.0
    m.votes.create :voter => Voter.gen, :score => 5.0
    m.reload.average_score.should == 3.5
  end

end