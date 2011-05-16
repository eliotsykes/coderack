# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

puts "Creating users..."
users = (1..30).map do
  u = User.new(
    :name => Faker::Internet.user_name.gsub(/\./, '_'),
    :email => Faker::Internet.email,
    :github_username => rand(2) == 1 ? Faker::Internet.user_name : nil,
    :twitter_username => rand(2) == 1 ? Faker::Internet.user_name : nil
  )
  u.identity_url = "http://" + Faker::Internet.domain_name
  u.save ? u : nil
end.compact

puts "Creating middlewares..."
middlewares = (1..80).map do
  owner = users.sample
  m = owner.middlewares.new(
    :name => (rand(2) == 1 ? "Rack " : "") + Faker::Company.catch_phrase.split(/ /)[1..-1].map(&:capitalize).join(' '),
    :about_source => Faker::Company.catch_phrase.capitalize,
    :details_source => Faker::Lorem.sentences.join(' '),
    :usage_source => Faker::Lorem.sentences.join(' '),
    :about_format => 'textile',
    :details_format => 'textile',
    :usage_format => 'textile',
    :project_page => rand(2) == 1 ? "http://github.com/#{Faker::Internet.user_name}/#{Faker::Internet.user_name}" : nil,
    :gem_name => rand(2) == 1 ? Faker::Internet.user_name : nil,
    :gist_id => rand(2) == 1 ? rand(1000000) : nil,
    :tag_names => Faker::Company.catch_phrase.downcase.split(/ /).join(', ')
  )
  m.save ? m : nil
end.compact

puts "Creating winners..."
winners = middlewares.sample(10)
winners.each_with_index do |m, i|
  m.finalist = true
  m.contest_place = i if i <= 4
  m.save!
end

puts "Creating votes..."
5.times do
  v = Voter.create :address => [rand(255), rand(255), rand(255), rand(255)].join('.')
  40.times do
    middlewares.sample.votes.create :voter => v, :score => rand(5) + 1
  end
end

puts "Done."
