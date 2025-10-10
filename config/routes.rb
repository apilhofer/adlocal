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
      patch :update_all_ad_positions  # Update positions for all ads
      post :render_all_ads        # Render all ads as final images
      post :unlock_all_ads       # Unlock all ads for editing
      post :regenerate_background # Regenerate background image
      post :proceed_to_editing   # Proceed to inline editing
      get :background_variants, defaults: { format: :json }  # Get background variants as JSON
    end
    resources :assets, only: [:create, :destroy]  # inspiration image management
  end

  # Ad Compositor routes
  resources :generated_ads, only: [] do
    member do
      get :compose
      patch :update_positions
      post :render_final
      post :unlock
    end
  end

  # ActionCable
  mount ActionCable.server => '/cable'

  # Defines the root path route ("/")
  root "home#index"
end
