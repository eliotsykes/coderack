module MiddlewaresHelper

  def available_formats
    IsFormattable::FORMATTERS.map { |f| [f.to_s.capitalize, f.to_s] }
  end

  def gist_url(middleware)
    "http://gist.github.com/#{middleware.gist_id}"
  end

  def rubygems_url(middleware)
    "http://rubygems.org/gems/#{middleware.gem_name}"
  end

  def current_request_url
    url = request.path
    url << '?' + request.query_string unless request.query_string.blank?
    url
  end

  def disqus_embed_url
    "http://disqus.com/forums/#{AppConfig.settings[:disqus_id]}/embed.js"
  end

  def disqus_link_url
    "http://#{AppConfig.settings[:disqus_id]}.disqus.com/?url=ref"
  end

end
