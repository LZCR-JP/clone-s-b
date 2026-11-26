Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  devise_for :users
  root to: "pages#home"
  get "about", to: "pages#about", as: :about

  # Host side (logged in)
  resources :nomikais do
    resources :invitations, only: %i[create destroy] do
      post :resend, on: :member
    end

    member do
      patch :close

      get :recommendations,
          action: :recommendations_landing,
          as: :recommendations_landing

      post :recommendations

      patch "candidates/:candidate_id/select",
            action: :select_candidate,
            as: :select_candidate
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
    resources :candidate_votes, only: :create
  end
end
