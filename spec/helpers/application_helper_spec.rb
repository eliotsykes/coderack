require 'spec_helper'

describe ApplicationHelper do

  include ApplicationHelper

  it "should print star icons representing average score" do
    m = Middleware.gen
    m.votes.create(:voter => Voter.gen, :score => 2.0)
    m.reload
    html = static_rating_stars(m)
    html.scan(/star_small.png/).should have(2).elements
    html.scan(/star_small_gray.png/).should have(3).elements

    m.votes.create(:voter => Voter.gen, :score => 4.0)
    m.reload
    html = static_rating_stars(m)
    html.scan(/star_small.png/).should have(3).elements
    html.scan(/star_small_gray.png/).should have(2).elements

    m.votes.create(:voter => Voter.gen, :score => 4.0)
    m.votes.create(:voter => Voter.gen, :score => 4.0)
    m.reload
    html = static_rating_stars(m)
    html.scan(/star_small.png/).should have(3).elements
    html.scan(/star_small_half.png/).should have(1).elements
    html.scan(/star_small_gray.png/).should have(1).elements
  end

end
