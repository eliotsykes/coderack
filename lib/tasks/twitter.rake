desc "Post tweets about new entries"
task :tweet_about_new_entries => :environment do
  puts "Started :tweet_about_new_entries task..."
  middlewares = Middleware.not_tweeted
  puts "Found #{middlewares.size} middlewares to tweet about."
  middlewares.each { |m| m.post_to_twitter! }
  puts "Finished :tweet_about_new_entries task."
end
