Rails.application.routes.draw do
  root "questions#index"

  namespace :admins do
    root "questions#index", as: :admin_root

    resources :questions, except: [ :show ]
  end
end
