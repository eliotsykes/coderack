class ExceptionsController < ApplicationController

  def unauthenticated
    options = env['warden.options']
    openid_response = options && options[:openid] && options[:openid][:response]
    if openid_response
      session[:identity_url] = openid_response.identity_url
      redirect_to new_user_path
    else
      flash[:warden_message] = warden.message
      redirect_to login_users_path
    end
  end

end
