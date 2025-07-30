Rails.application.routes.draw do
  get "home/index"
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  # 2FA routes
  get "two_factor/setup", to: "two_factor#setup", as: :setup_two_factor
  post "two_factor/verify", to: "two_factor#verify", as: :verify_two_factor
  delete "two_factor/disable", to: "two_factor#disable", as: :disable_two_factor

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "home#index"
end
