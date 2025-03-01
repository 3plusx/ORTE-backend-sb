Rails.application.routes.draw do

  devise_for :users

  if Rails.env.production?
    I18n.available_locales.each_with_index do |locale, i|
      root :to => 'public/submissions#new', locale: locale.to_s ,layer_id: 51, bogus_id: i, constraints: { host: 'submissions.stiftung-lager-sandbostel.de', query_string: 'locale=' + locale.to_s  }
    end
    root :to => 'public/submissions#new', locale: 'de', layer_id: 51, bogus_id:23, constraints: { host: 'submissions.stiftung-lager-sandbostel.de'  }
  elsif Rails.env.development?
    I18n.available_locales.each_with_index do |locale, i|
      root :to => 'public/submissions#new', locale: locale.to_s ,layer_id: 1, bogus_id: i, constraints: { host: 'localhost', port: '3000', query_string: 'locale=' + locale.to_s  }
    end
    root :to => 'public/submissions#new', locale: 'de' ,layer_id: 1, bogus_id:23, constraints: { host: 'localhost', port: '3000'  }
  else
    I18n.available_locales.each_with_index do |locale, i|
      root :to => 'public/submissions#new', locale: locale.to_s ,layer_id: 2, bogus_id: i, constraints: { host: 'submissions-staging.stiftung-lager-sandbostel.de', query_string: 'locale=' + locale.to_s  }
    end
    root :to => 'public/submissions#new', locale: 'de', layer_id: 2, bogus_id:23, constraints: { host: 'submissions-staging.stiftung-lager-sandbostel.de'  }
  end

  root 'start#index'

  get 'info', to: 'start#info'

  match 'preferences' => 'preferences#edit', :as => :preferences, via: [:get, :patch]

  get 'bomb',        to: 'application#bomb'
  post 'report_csp', to: 'application#report_csp'

  # settings
  get   'settings',    to: 'start#settings'
  # profile
  get   'edit_profile',    to: 'start#edit_profile'
  patch 'update_profile',  to: 'start#update_profile'

  resources :iconsets do
    resources :icons, only: [:edit, :destroy, :update]
  end
  resources :maps do
    resources :tags, only: [:index, :show]
    resources :layers do
      collection do
        post :search
      end
      member do
        get :images, only: [:index]
      end
      resources :places do
        resources :images
        resources :videos
        member do
          delete :delete_image_attachment
          post :sort
        end
      end
    end
  end

  namespace :admin do
    resources :users
    resources :groups
  end

  scope "/:locale" do
    scope "/:layer_id" do
      resources :submissions, :controller => "public/submissions" do
        get :new, :controller => "public/submissions", :action => 'new'
        post :create, :controller => "public/submissions", :action => 'create'    
        get :edit, :controller => "public/submissions", :action => 'edit'
        patch :update, :controller => "public/submissions", :action => 'update'
        get :new_place, :controller => "public/submissions", :action => 'new_place'
        post :create_place, :controller => "public/submissions", :action => 'create_place'
        scope "/:place_id" do
          get :edit_place, :controller => "public/submissions", :action => 'edit_place'
          patch :update_place, :controller => "public/submissions", :action => 'update_place'
          get :new_image, :controller => "public/submissions", :action => 'new_image'
          post :create_image, :controller => "public/submissions", :action => 'create_image'
          get :finished, :controller => "public/submissions", :action => 'finished'
        end
      end
    end
  end


  constraints subdomain: 'submissions-staging.stiftung-lager-sandbostel.de' do


  end
  namespace :public do
    resources :maps, only: [:show, :index], :defaults => { :format => :json } do
      resources :layers, only: [:show], :defaults => { :format => :json }
    end
  end

end
