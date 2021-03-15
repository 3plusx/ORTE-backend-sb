Rails.application.routes.draw do

  devise_for :users

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
    resources :submissions, :controller => "public/submissions" do
      get :new
      get :new_place, :controller => "public/submissions", :action => 'new_place'
      post :create_place, :controller => "public/submissions", :action => 'create_place'
      get :new_image, :controller => "public/submissions", :action => 'new_image'
      post :create_image, :controller => "public/submissions", :action => 'create_image'
      get :finished, :controller => "public/submissions", :action => 'finish_submission'

    end
  end

  namespace :public do
    resources :maps, only: [:show, :index], :defaults => { :format => :json } do
      resources :layers, only: [:show], :defaults => { :format => :json }
    end
  end

end
