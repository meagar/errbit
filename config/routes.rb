Errbit::Application.routes.draw do

  devise_for :users, :controllers => (Errbit::Config::cas_server ? { :omniauth_callbacks => 'sessions/cas', :sessions => 'sessions/cas' } : { } )

  # Hoptoad Notifier Routes
  match '/notifier_api/v2/notices' => 'notices#create'
  match '/deploys.txt' => 'deploys#create'
 
  match 'users/no-authorization' => 'sessions/cas#no_authorization', :as => 'no_authorization'

  resources :notices, :only => [:show]
  resources :deploys, :only => [:show]
  resources :users
  resources :errs,    :only => [:index] do
    collection do
      get :all
    end
  end
  
  resources :apps do
    resources :errs do
      resources :notices
      member do
        put :resolve
        post :create_issue
        delete :clear_issue
      end
    end

    resources :deploys, :only => [:index]
  end
  
  devise_for :users
  
  root :to => 'apps#index'
  
end
