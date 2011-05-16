require 'spec_helper'

describe Middleware do

  it "should be valid when generated" do
    Middleware.prepare.should be_valid
  end

  it "should validate name presence and length" do
    Middleware.prepare(:name => nil).should_not be_valid
    Middleware.prepare(:name => "").should_not be_valid
    Middleware.prepare(:name => "AA").should_not be_valid
    Middleware.prepare(:name => "A" * 255).should be_valid
    Middleware.prepare(:name => "A" * 256).should_not be_valid
  end

  it "should validate name uniqueness" do
    Middleware.gen(:name => "foo").should be_valid
    Middleware.prepare(:name => "foo").should_not be_valid
  end
  
  it "should validate presence and length of about/usage" do
    Middleware.prepare(:about_source => nil).should_not be_valid
    Middleware.prepare(:about_source => "").should_not be_valid
    Middleware.prepare(:about_source => "A" * 460).should be_valid
    Middleware.prepare(:about_source => "A" * 501).should_not be_valid

    Middleware.prepare(:usage_source => nil).should_not be_valid
    Middleware.prepare(:usage_source => "").should_not be_valid
    Middleware.prepare(:usage_source => "A" * 9960).should be_valid
    Middleware.prepare(:usage_source => "A" * 10001).should_not be_valid
  end
  
  it "should validate user_id" do
    Middleware.prepare(:user => nil).should_not be_valid
  end

  it "should validate GitHub page url" do
    Middleware.prepare(:project_page => nil).should be_valid
    Middleware.prepare(:project_page => "").should be_valid
    Middleware.prepare(:project_page => "http://github.com/psionides/MacBlip").should be_valid
    Middleware.prepare(:project_page => "http://github.com/psionides/MacBlip/master").should be_valid
    Middleware.prepare(:project_page => "http://github.com/psionides/").should_not be_valid
    Middleware.prepare(:project_page => "http://github.com/psionides").should_not be_valid
    Middleware.prepare(:project_page => "http://github.com/").should_not be_valid
    Middleware.prepare(:project_page => "http://icanhascheezburger.com/").should_not be_valid
  end
  
  it "should be valid without a gist id" do
    Middleware.prepare(:gist_id => nil).should be_valid
    Middleware.prepare(:gist_id => '').should be_valid
  end

  it "should validate gist id" do
    Middleware.prepare(:gist_id => "jola").should_not be_valid
    Middleware.prepare(:gist_id => "http://gist.github.com/foobar").should_not be_valid
    Middleware.prepare(:gist_id => 108935).should be_valid
    Middleware.prepare(:gist_id => "http://gist.github.com/108935").should be_valid
    Middleware.prepare(:gist_id => 1_000_000_000).should be_valid
  end
  
  it "should be paginated" do
    Middleware.respond_to?(:page).should be_true
  end

  it "should extract gist_id from gist url" do
    m = Middleware.prepare
    m.gist_id = "http://gist.github.com/108935"
    m.gist_id.should == 108935
  end

  it "should sanitize name, description and usage" do
    m = Middleware.gen(:name => %q{<strong>Big</strong> title}, 
                       :about_source => %q{This <b>is</b> <script>alert('attack!')</script>},
                       :usage_source => %q{Another <pre>try</pre> of <script>alert('attack!')</script>})
    m.name.should == 'Big title'
    m.about.should match(/This.+alert/)
    m.about.should_not match(/<script/)
    m.usage.should match(/Another.+try.+of/)
    m.usage.should_not match(/<script/)
  end

  it "should tweet if not already tweeted" do
    m = Middleware.gen :name => 'Awesome Middleware'
    client = mock('client')
    client.expects(:update).
           with { |text| text =~ /middleware/ && text =~ /submitted/ && text =~ /coderack\.org/ &&
                         text =~ /Awesome Middleware/ && text =~ %r(http://bit.ly/asd) }.
           returns(nil)
    m.expects(:twitter_client).returns(client)
    m.expects(:shorten_url).returns("http://bit.ly/asd")
    m.stubs(:puts)

    m.post_to_twitter!
    m.should be_tweeted
  end
  
  it "shouldn't tweet if already tweeted" do
    m = Middleware.gen(:tweeted => true)
    m.expects(:twitter_client).never
    m.expects(:shorten_url).never
    m.post_to_twitter!
    m.should be_tweeted
  end
  
  it "should assign tags" do
    tag_names = %w(html ruby)
    m = Middleware.gen
    m.tags.size.should == 0
    m.tag_names = tag_names.join(' ,  ')
    m.tags.size.should == tag_names.size
    m.tag_names.should == tag_names.join(', ')
  end
  
  it "should search middleware" do
    m1 = Middleware.gen(:name => 'Rack::JSON', :about_source => 'A simple rack middleware to persist JSON documents.')
    m2 = Middleware.gen(:name => 'Rack::Identity', :about_source => 'The simplest Rack middleware ever.')

    Middleware.search(['simple']).size.should == 2
    Middleware.search(['json']).size.should == 1
  end

  it "should calculate average score rounded to given precision" do
    m = Middleware.gen
    m.votes.create(:voter => Voter.gen, :score => 2.0)
    m.votes.create(:voter => Voter.gen, :score => 4.0)
    m.votes.create(:voter => Voter.gen, :score => 5.0)
    m.reload
    m.average_score_rounded(1.0).should == 4.0
    m.average_score_rounded(0.5).should == 3.5
    m.average_score_rounded(0.01).should == 3.67
  end

  it "should be displayed as URL-friendly form of the name in URLs" do
    m = Middleware.gen :name => 'Rack::Awesome -- Awesome Middleware!'
    m.name = 'changed'
    m.to_param.should == "#{m.id}-rackawesome-awesome-middleware"
  end

  it "should say if at least one link (to gist, project page or rubygems) has been set" do
    m = Middleware.new :project_page => 'http://github.com/foo'
    m.has_any_links?.should be_true
    m = Middleware.new :gem_name => 'foo'
    m.has_any_links?.should be_true
    m = Middleware.new :gist_id => 234234
    m.has_any_links?.should be_true
    m = Middleware.new
    m.has_any_links?.should be_false
  end

  describe "sorting" do
    it "should sort by newest uploaded by default" do
      Middleware.sorted(nil).should == Middleware.order('created_at DESC')
    end

    it "should sort by highest score and then by newest uploaded if sort = score" do
      Middleware.sorted('score').should == Middleware.order('average_score DESC, created_at DESC')
    end
  end

  it "should find not tweeted middlewares" do
    @tweeted = Middleware.gen :tweeted => true
    @not_tweeted = Middleware.gen :tweeted => false
    Middleware.not_tweeted.should include(@not_tweeted)
    Middleware.not_tweeted.should_not include(@tweeted)
  end

  it "should find finalists" do
    @finalist = Middleware.gen :finalist => true
    @other = Middleware.gen :finalist => false
    Middleware.finalists.should include(@finalist)
    Middleware.finalists.should_not include(@other)
  end

  it "should not let user change middleware ownership by hacking a form" do
    m = Middleware.gen
    owner = m.user
    other_user = User.gen

    m.update_attributes :user_id => other_user.id
    m.reload.user.should == owner

    m.update_attributes :user => other_user
    m.reload.user.should == owner

    m.user = other_user
    m.save
    m.reload.user.should == other_user
  end

  it "should not let user mark middleware as finalist or contest winner by hacking a form" do
    m = Middleware.gen :finalist => false
    m.update_attributes :finalist => true
    m.reload.should_not be_a_finalist

    m.finalist = true
    m.save
    m.reload.should be_a_finalist

    m = Middleware.gen :contest_place => nil
    m.update_attributes :contest_place => 1
    m.reload.contest_place.should be_nil

    m.contest_place = 1
    m.save
    m.reload.contest_place.should == 1
  end

  it "should use markdown or textile to format the fields" do
    m = Middleware.gen(
      :details_source => 'This is `source.code(true)`.',
      :details_format => 'markdown'
    )
    m.details.strip.should == "<p>This is <code>source.code(true)</code>.</p>"

    m = Middleware.gen(
      :details_source => '`This` is **spartaa!**',
      :details_format => 'textile'
    )
    m.details.strip.should == "<p>`This` is <b>spartaa!</b></p>"
  end

  it "should say if middleware is a contest winner (top 3 places)" do
    m = Middleware.gen
    m.should_not be_a_contest_winner
    [1, 2, 3].each { |i| m.contest_place = i; m.save; m.should be_a_contest_winner }
    [4, 9, 666].each { |i| m.contest_place = i; m.save; m.should_not be_a_contest_winner }
  end

  it "should return contest winners and honorable mention" do
    middlewares = [1, 2, 3, 4, 5, 9, nil].map { |i| Middleware.gen :contest_place => i }
    winners = Middleware.contest_winners
    winners.count.should == 3
    winners.should include(middlewares[0])
    winners.should include(middlewares[1])
    winners.should include(middlewares[2])
    Middleware.honorable_mention.to_a.should == [middlewares[3]]
  end

end
