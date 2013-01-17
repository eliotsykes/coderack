module ApplicationHelper

  def static_rating_stars(middleware)
    html = ""
    rating = middleware.average_score_rounded(0.5)
    html << image_tag('star_small.png') * (rating.to_i)
    html << image_tag('star_small_half.png') if rating > rating.to_i
    html << image_tag('star_small_gray.png') * ((5 - rating).to_i)
    info = if middleware.votes.count > 0
      "Score: #{middleware.average_score_rounded(0.01)}, votes: #{middleware.votes.count}"
    else
      "No votes yet"
    end
    content_tag :span, html.html_safe, :class => 'static_rating', :title => info
  end

  def tags(middleware)
    content_tag :span, tag_links(middleware), :class => :tags unless middleware.tags.empty?
  end

  def tag_links(middleware)
    middleware.tags.map { |i| tag_link(i) }.join(', ').html_safe
  end

  def tag_link(tag_model)
    link_to(tag_model.name, tagged_middlewares_path(:tag => tag_model.name))
  end

  def sort_url(sort)
    args = params.dup
    %w(page format action controller name id).each { |a| args.delete(a) }
    args['sort'] = sort
    request.path + "?" + args.map { |k, v| "#{k}=#{url_encode(v)}" }.join("&")
  end

  def error_on(object, attribute)
    error = object.errors[attribute].try(:first)
    error ? content_tag(:span, error.strip, :class => 'error') : ""
  end

  def gravatar_url(email, size = 60)
    hash = Digest::MD5.hexdigest(email.to_s.downcase)
    default = CGI.escape("http://#{request.env['HTTP_HOST']}/images/avatar-placeholder.png")
    "http://www.gravatar.com/avatar/#{hash}?s=#{size}&d=#{default}"
  end

  def menu_item(name, path, id)
    link_to(name, path, :class => "menuitem #{selected_menu_item == id ? 'active' : ''}")
  end

  def format_time(time)
    time.to_s(:long)
  end

end
