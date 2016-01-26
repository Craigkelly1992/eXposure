Rails.application.routes.draw do


  devise_for :admins do
    root :to => "admins#users"
  end
  resources :posts do
    resources :comments, shallow: true
  end

  resources :contests do
    member do
      post 'set_winner'
      get 'winner_window'
    end
    collection do
      get 'my', path: "my_contests"
    end
  end

  resources :brands do
    collection do
      get 'my', path: "my_brands"
      post :visit_brand_social
    end
  end
  post '/admins/agencies/:agency_id/disable' => 'admins#disable_agency', as: 'disable_agency'
  post '/admins/agencies/:agency_id/enable' => 'admins#enable_agency', as: 'enable_agency'
  post '/admins/users/:user_id/disable' => 'admins#disable_user', as: 'disable_user'
  post '/admins/users/:user_id/enable' => 'admins#enable_user', as: 'enable_user'
  delete '/admins/agencies/:agency_id/delete' => 'admins#delete_agency', as: 'delete_agency'
  delete '/admins/users/:user_id/delete' => 'admins#delete_user', as: 'delete_user'
  get '/admins/agencies' => 'admins#agencies', as: 'admin_agencies'
  get '/admins/users' => 'admins#users', as: 'admin_users'
  get '/admins' => 'admins#users', as: 'admin_root_path'


  resources :notifications

  devise_for :agencies, controllers: {registrations: "agency_registrations"}
  devise_for :users, :controllers => {passwords: "password" }
  post '/users/password' => 'password#create', :as => :user_forgot_password, :via => :post
  get 'agencies/change_password' => 'agencies#change_password'
  post 'agencies/update_password' => 'agencies#update_password'

  #namespace :api, :path => "", :defaults => {:format => :json}, :constraints => {:subdomain => "api"} do
  namespace :api, :defaults => {:format => :json} do

    resources :posts do
      member do
        get 'comments'
        post 'like'
        post 'unlike'
      end
      collection do
        get 'by_brand'
        get 'by_user'
        get 'by_contest'
        get 'my', path: "my_posts"
        get 'stream'
        get :show_without_authenticate
      end
    end
    resources :contests do
      collection do
        get 'by_brand'
        get 'by_following'
      end
      member do
        post 'claim_prize'
      end
    end

    resources :brands do
      member do
        post 'click'
        post 'follow'
        post 'unfollow'
        get 'check_follow'
      end
    end

    resources :comments

    # this has to come first to match
    get 'users/login' => 'users#login'
    resources :users do
      collection do
        get 'search'
        get :get_users
        post :update_facebook
        post :update_twitter
        post :update_instagram
      end
      member do
        post 'follow'
        post 'unfollow'
        get 'check_follow'
        post 'save_token'
        get 'followers'
        get 'following'
        get 'contests'
        get 'get_all_expose_of_user'
      end
    end
    post 'profile/update' => 'users#update_my_profile', as: 'update_profile'
    get 'profile' => 'users#profile'

    resources :notifications, only: :index do
      collection do
        post :read_notification
        get :count_unread_notifications
      end
    end

    resources :agencies

    get 'rankings/global' => 'rankings#global'
    get 'rankings/followers' => 'rankings#followers'
    get 'rankings/following' => 'rankings#following'

  end


  root 'brands#my'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  get "/404", :to => "errors#not_found"
  get "/422", :to => "errors#unacceptable"
  get "/500", :to => "errors#internal_error"

end
