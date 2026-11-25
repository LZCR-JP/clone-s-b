Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  devise_for :users
  root to: "pages#home"

  # Host side (logged in)
  resources :nomikais do
    member do
      patch :close
      patch :regenerate_code
    end

    resources :invitations, only: %i[create destroy] do
      member do
        post :resend
      end
    end
  end

  # Colleague side (no account, identified by tokens or a join code)
  get "join", to: "join_codes#new", as: :join_code
  post "join", to: "join_codes#create", as: nil

  get "join/code/:code", to: "participants#new", as: :join_with_code
  post "join/code/:code", to: "participants#create"

  get "invite/:invite_token", to: "participants#new", as: :invite
  post "invite/:invite_token", to: "participants#create"

  get "join/:share_token", to: "participants#new", as: :join
  post "join/:share_token", to: "participants#create"

  resources :participants, only: :show, param: :token do
    resources :swipes, only: %i[index create]
  end
end
