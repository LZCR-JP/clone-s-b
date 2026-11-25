Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  # Host side (logged in)
  resources :nomikais do
    member do
      patch :close
      get :recommendations, action: :recommendations_landing, as: :recommendations_landing
      post :recommendations
    end
  end

  # Colleague side (no account, identified by tokens)
  get "join/:share_token", to: "participants#new", as: :join
  post "join/:share_token", to: "participants#create"

  resources :participants, only: :show, param: :token do
    resources :swipes, only: %i[index create]
  end
end
