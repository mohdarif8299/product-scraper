Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      resources :products, only: [:index, :create]
      resources :categories, only: [:index]
    end
  end
end