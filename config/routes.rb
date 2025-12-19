Rails.application.routes.draw do
  namespace :operator do
    root "top#index"
    resources :runs, only: [:index, :show, :new, :create]
  end

end
