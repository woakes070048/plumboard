Plumboard::Application.routes.draw do

  devise_for :users, :controllers => { registrations: "registrations", sessions: "sessions" } 
  
  devise_scope :user do
    get "signup" => "registrations#new", as: :new_user_registration
    post "signup" => "registrations#create", as: :user_registration
    get "signout" => "sessions#destroy", as: :destroy_user_session
  end

  # resource defs
  resources :listings, except: [:new] do
    collection do
      get 'seller', 'follower'
    end
  end

  resources :users, except: [:new]
  resources :temp_listings 
  
  resources :transactions do
    get 'build', :on => :collection
    get 'refund', :on => :collection
  end

  # match routes
  get "/about", to: "pages#about" 
  get "/privacy", to: "pages#privacy" 
  get "/help", to: "pages#help" 
  get "/contact", to: "pages#contact" 
  get "/welcome", to: "pages#welcome" 
  get '/system/:class/:attachment/:id/:style/:filename', :to => 'pictures#asset'
  # post "/listings/preview", to: "listings#preview", :via => :post, :as => :preview 
  # post "/listings/new", to: "listings#new", :via => :post, :as => :new_post_listing 
  put "/temp_listings/submit_order/:id", to: "temp_listings#submit_order", :via => :put, :as => :submit_order 

  # specify routes for devise user after sign-in
  namespace :user do
    root :to => "users#show", :as => :user_root
  end

  root to: 'pages#home'
end
