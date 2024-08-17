Rails.application.routes.draw do
  get("partnership_requests/new")
  get("partnership_requests/create")
  devise_for(:users)
  resources(:users)
  get("/me", to: "users#show", as: :my_profile)
  resources(:partnership_requests, only: [ :create ]) do
    member do
      patch(:accept)
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root("caves#index")
  resources(:caves) do
    resources(:logs, only: [ :new, :create ])
    resources(:locations, only: [ :new, :create, :show, :edit, :update ])
    resources(:subsystems, only: [ :new, :create, :show, :edit, :update ]) do
      resources(:locations, only: [ :new, :create, :show, :edit, :update ])
    end
  end

  resources(:logs) do
    member do
      post("add_location")
      post("remove_location")
      get("/edit_cave_locations/:cave_id", to: "logs#edit_cave_locations", as: :edit_cave_locations)

      post("remove_unconnected_location")
      get("edit_unconnected_locations")

      post("add_cave")
      post("remove_cave")
      post("remove_unconnected_cave")
      get("edit_caves")
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get("up" => "rails/health#show", :as => :rails_health_check)

  # Render dynamic PWA files from app/views/pwa/*
  get("service-worker" => "rails/pwa#service_worker", :as => :pwa_service_worker)
  get("manifest" => "rails/pwa#manifest", :as => :pwa_manifest)
  # Defines the root path route ("/")
  # root "posts#index"
end
