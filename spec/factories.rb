FactoryGirl.define do 

  factory :user do
    sequence(:name) { |n| "user_#{n}" }
    email { |user| "#{user.name}@coderack.com" }
    identity_url { |user| "http://#{user.name}.mp" }
  end

  factory :middleware do
    sequence(:name) { |n| "Cool Middleware ##{n}" }
    about_source 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam ut elit erat. In in metus lorem, quis iaculis mi.'
    about_format 'textile'
    details_source 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam ut elit erat. In in metus lorem, quis iaculis mi. Praesent tempus vulputate rhoncus. Cras ullamcorper accumsan laoreet. Nam sagittis mollis quam, ut egestas purus pulvinar id. Sed nisl diam, porttitor in pretium in, lobortis ac dolor. Aenean lacinia semper tellus sit amet dignissim. Vivamus eget volutpat nunc. Integer nisl enim, viverra eget interdum vel, eleifend vitae mauris. Aenean rhoncus magna et dui egestas facilisis facilisis nisi tincidunt. Proin eget lectus enim, nec sollicitudin metus. In vitae lectus a ante sagittis semper sit amet sed est. Sed rutrum, enim nec ultricies ultrices, leo ligula mattis ligula, eu lacinia nisi purus eu urna. Nulla non erat augue. Quisque luctus mauris non metus feugiat pellentesque. Nunc ac turpis lectus. Integer sit amet iaculis justo. Maecenas risus turpis, vulputate a mollis et, pulvinar sed nibh. Nulla facilisi.'
    details_format 'textile'
    usage_source '<pre><code>use ThisCode</code></pre>'
    usage_format 'textile'
    sequence(:gist_id) { |n| "http://gist.github.com/#{66666+n}" }
    association(:user)
    tweeted false
  end

  factory :voter do
    address "127.0.0.1"
  end
end
