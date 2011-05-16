xml.instruct! :xml, :version => '1.0', :encoding => 'UTF-8'

xml.feed :xmlns => "http://www.w3.org/2005/Atom" do |feed|

  feed.id(root_url)
  feed.title "CodeRack"
  feed.subtitle "A warm place to hang your code"
  feed.link :href => root_url, :rel => 'alternate', :type => 'text/html'
  feed.link :href => middlewares_url(:format => 'xml'), :rel => 'self', :type => 'application/atom+xml'
  feed.updated @middlewares.first.updated_at

  feed.author do |author|
    author.name "Lunar Logic Polska"
    author.email "info@coderack.org"
  end

  @middlewares.each do |middleware|
    feed.entry do |entry|
      entry.id(middleware_url(middleware))
      entry.title(middleware.name)
      entry.published(middleware.created_at)
      entry.updated(middleware.updated_at)
      entry.link :href => middleware_url(middleware)
      entry.content(middleware.about + middleware.details.to_s + middleware.usage, :type => 'html')
    end
  end

end
