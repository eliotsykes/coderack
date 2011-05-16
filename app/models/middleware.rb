class Middleware < ActiveRecord::Base

  include IsFormattable
  include Rails.application.routes.url_helpers
  default_url_options[:host] = AppConfig.settings[:site_url].gsub(/http:\/\//, '')
  paginates_per 10

  NAME_CUT_REGEX = /<[\w\/][^>]*>/
  GITHUB_REGEX = /^http:\/\/(www\.)?github.com\/[\w\-\.]+\/[\w\-\.]+/

  validates_presence_of :name, :about_format, :about, :details_format, :usage, :usage_format, :user
  validates_uniqueness_of :name
  validates :name, :length => { :minimum => 3, :maximum => 255 }
  validates :about, :length => { :maximum => 500 }
  validates :details, :length => { :maximum => 10_000 }
  validates :usage, :length => { :maximum => 10_000 }
  validates :project_page, :format => { :with => GITHUB_REGEX }, :length => { :maximum => 200 }, :allow_blank => true
  validates :gem_name, :format => { :with => /^[\w\-]+$/ }, :length => { :maximum => 50 }, :allow_blank => true
  validates :gist_id, :numericality => true, :allow_blank => true

  belongs_to :user
  has_many :votes
  has_and_belongs_to_many :tags

  attr_protected :user, :user_id, :finalist, :contest_place

  before_validation do
    self.name.gsub!(NAME_CUT_REGEX, '') if self.name.is_a?(String)
  end
  
  is_formattable([
    { :in_property => :about_source,   :out_property => :about,   :format_property => :about_format },
    { :in_property => :details_source, :out_property => :details, :format_property => :details_format },
    { :in_property => :usage_source,   :out_property => :usage,   :format_property => :usage_format }
  ])

  scope :not_tweeted, where(:tweeted => false)
  scope :finalists, where(:finalist => true)
  scope :honorable_mention, where(:contest_place => 4)
  scope :contest_winners, where('contest_place <= 3')

  def self.sorted(sort)
    fields = (sort == 'score') ? 'average_score DESC, created_at DESC' : 'created_at DESC'
    self.order(fields)
  end

  def self.search(terms)
    likes = []
    search_columns = ['name', 'about_source']
    query = terms.map do |t|
      '(' + search_columns.map do |c|
        likes << "%#{t}%"
        "#{c} LIKE ?"
      end.join(' OR ') + ')'
    end.join(' AND ')
    
    conditions = terms.empty? ? {} : [query].concat(likes)
    self.where(conditions)
  end

  def has_any_links?
    [:project_page, :gem_name, :gist_id].any? { |f| !self.send(f).blank? }
  end

  def gist_id=(val)
    if val.is_a?(String) && val =~ /\d+/
      val = val[/\d+/]
    elsif val.is_a?(String) && val.blank?
      val = nil
    end
    write_attribute(:gist_id, val)
  end

  def slug
    "#{id}-#{name_was.downcase.strip.gsub(/\s+/, '-').gsub(/[^a-z0-9-]/, '').gsub(/-{2,}/, '-')}"
  end

  def to_param
    slug
  end

  def average_score_rounded(precision)  # e.g. precision = 0.5
    (average_score / precision).round * precision  # round it to 0.5
  end

  def update_average_score
    self.update_attributes :average_score => self.votes.average(:score)
  end

  def post_to_twitter!
    return if self.tweeted

    url = shorten_url(user_middleware_url(self.user, self))
    text = "New #ruby #rack #middleware submitted to #coderack.org: #{self.name.truncate(55)} #{url}"

    begin
      twitter_client.update(text)
      self.tweeted = true

      if save
        puts "Successfully tweeted about new middleware ##{self.id} to '#{twitter_login}' account"
      else
        errors = self.errors.full_messages.join(', ')
        puts "Problem while marking middleware ##{self.id} as tweeted: #{errors}"
      end
    rescue => e
      puts "Problem while tweeting about middleware ##{self.id}: #{e.message} (#{e.backtrace.first})"
    end
  end

  def tag_names=(list)
    new_tags = list.split(',').map { |name| Tag.find_by_name(name.strip) || Tag.create(:name => name.strip) }
    tags.replace(new_tags)
  end

  def tag_names
    tags.map(&:name).join(', ')
  end

  def contest_winner?
    Middleware.contest_winners.map(&:id).include?(self.id)
  end


  private

  def bitly
    if @bitly.nil?
      data = AppConfig.settings[:bitly]
      Bitly.use_api_version_3
      @bitly = Bitly.new(data[:username], data[:key])
    end
    @bitly
  end

  def shorten_url(url)
    bitly.shorten(url).short_url
  end

  def twitter_login
    AppConfig.settings[:twitter][:login]
  end

  def twitter_client
    if @twitter_client.nil?
      consumer = AppConfig.settings[:twitter][:consumer]
      access = AppConfig.settings[:twitter][:access]

      oauth = Twitter::OAuth.new(consumer[:key], consumer[:secret])
      oauth.authorize_from_access(access[:key], access[:secret])

      @twitter_client = Twitter::Base.new(oauth)
    end
    @twitter_client
  end

end
