module UsersHelper

  def user_github_page_url(user)
    "http://github.com/#{user.github_username}"
  end

  def twitter_profile_url(user)
    "http://twitter.com/#{user.twitter_username}"
  end

end
