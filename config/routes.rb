Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authentication
  devise_for :users

  # Business and contact people routes
  resource :business, only: [:show, :new, :create, :edit, :update] do
    resources :contact_people, except: [:show]
  end

  # Campaign routes
  resources :campaigns do
    member do
      post :generate_suggestions  # AI brief suggestions
      post :generate_ads          # AI ad generation
      delete :delete_ads          # Delete all generated ads
    end
    resources :assets, only: [:create, :destroy]  # inspiration image management
  end

  # ActionCable
  mount ActionCable.server => '/cable'

  # Defines the root path route ("/")
  root "home#index"
end
