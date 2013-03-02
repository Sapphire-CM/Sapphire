Sapphire::Application.routes.draw do

  devise_for :accounts

  resources :courses do
    resources :terms do
      get :meeting
      resources :tutorial_groups
      resources :exercises do
        resources :rating_groups do
          resources :ratings
        end
    
        resources :evaluations
      end
      
      namespace :import do
        resources :student_imports do
          put :import, :on => :member
        end
      end
    end
  end

  get '/:action', :controller => :static, :as => :static
  root :to => 'static#index'
  
end
