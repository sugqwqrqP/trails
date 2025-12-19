Rails.application.routes.draw do

  #------------------------------

  # ＜利用者＞

  # トップ
  root "top#index"

  # 便
  resources :runs, only: [] do

    resources :cars, only: [:index] do
      resources :seats, only: [:index]
    end
  end

  # 予約
  resources :reservations, only: [:create] do
    get :confirm,  on: :collection
    get :complete, on: :collection
  end

  # 利用者
  resources :users, only: [:new, :create, :show, :edit, :update] do
    resources :reservations, only: [:show, :destroy]
  end

  # ログイン（単数リソース）
  resource :login, only: [:new, :create, :destroy]

  #------------------------------

  # ＜運行管理者＞

  namespace :operator do
    root "top#index"
    resources :runs, only: [:index, :show, :new, :create]
  end

  #------------------------------

  # ＜駅員＞

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
