Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # root path route ("/")
  root "landing_page#about"  

  
  post "/login", to: "auth#login"
  post "/signup", to: "auth#create"

  get "/login", to: "auth#new_login"
  get "/signup", to: "auth#new_signup"
  get "/about", to: "landing_page#about"
  delete "/logout", to: "auth#logout"


  resources :subjects do
    resources :collaborations
    resources :chapters do 
      resources :paragraphs do
        resources :questions do
          resources :answers, only: [:create, :update, :destroy, :edit]
        end
      end
    end
  end


  match "*path", to: "not_found#show", via: :all

end
