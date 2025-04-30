Rails.application.routes.draw do
	root 'questions#index'
	
	namespace :admins do
		resources :questions, except: [:show]
	end
end
