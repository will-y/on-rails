Rails.application.routes.draw do
  resources :users
  resource :sessions

  post '/sign_up/:User', to: 'sign_up#sign_up_post'
  get 'sign_up/', to: 'sign_up#sign_up'
  get 'sign_up/total', to: 'sign_up#index'

  get 'cassandra', to: 'cassandra#index'

  root 'home#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
