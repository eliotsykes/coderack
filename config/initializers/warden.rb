Rails.configuration.middleware.use Rack::OpenID
Rails.configuration.middleware.use Warden::Manager do |manager|
  manager.default_strategies :openid
  if Rails.env.development?
    # in development, look up the class dynamically because it will be reloaded
    manager.failure_app = lambda { |env| 'ExceptionsController'.constantize.action(:unauthenticated).call(env) }
  else
    manager.failure_app = ExceptionsController.action(:unauthenticated)
  end
end

Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  User.find_by_id(id)
end

Warden::OpenID.configure do |config|
  config.user_finder do |response|
    User.find_by_identity_url(response.identity_url)
  end
end
