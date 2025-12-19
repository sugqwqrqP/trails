Rails.application.routes.draw do

  #運行管理者
  namespace :operator do
    root "top#index"
    resources :runs, only: [:index, :show, :new, :create]
  end

  #駅員
  namespace :staff do
    root "top#index"

    #便、号車、席のネスト
    resources :runs, only: [:index, :show] do
      resources :cars, only: [:index] do
        resources :seats, only: [:index]
      end
    end

    #利用者、予約のネスト
    resources :users, only: [:index, :show] do
      resources :reservations, only: [:show]
    end

    #予約単体のネスト
    resources :reservations, only: [:index, :show, :create] do
      get :confirm,  on: :collection
      get :complete, on: :collection
    end
  end

end
