Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    resources :products
    get 'demo_partials/new'
    get 'demo_partials/edit'
    get 'static_pages/home'
    get 'static_pages/help'
    resources :users
  end
end