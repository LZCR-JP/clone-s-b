Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  # Host side (logged in)
  resources :nomikais, only: %i[index new create show destroy] do
    member do
      patch :close
    end
  end

  # Colleague side (no account, identified by tokens)
  get "join/:share_token", to: "participants#new", as: :join
  post "join/:share_token", to: "participants#create"

  resources :participants, only: :show, param: :token do
    resources :swipes, only: %i[index create]
  end
end
