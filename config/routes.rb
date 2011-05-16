Coderack::Application.routes.draw do

  root :to => 'static_pages#home'

  match "/about" => "static_pages#about", :as => 'about'
  match "/archive" => "static_pages#archive", :as => 'archive'

  match "/users/:user/entries/:middleware" => redirect("/users/%{user}/middlewares/%{middleware}")

  resources :users do
    resources :middlewares
    collection do
      match :login
      get :logout
    end
  end

  resources :middlewares do
    collection do
      get :mine
      get :search
      get :tagged
    end
    member do
      post :vote
    end
  end

end
