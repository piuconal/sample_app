Rails.application.routes.draw do
  get "relationships/create"
  get "relationships/destroy"
  root "static_pages#home"

  get "static_pages/home"
  get "static_pages/help"
  resources :static_pages, only: %i(home help)

  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
  resources :users, only: :show

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  resources :users, only: %i(new create show)
  # resources :users, only: %i(new create show edit update index destroy)
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :password_resets, only: %i(new create edit update)
  resources :account_activations, only: :edit

  resources :microposts, only: %i(create destroy)
  resources :relationships, only: %i(create destroy)
end
