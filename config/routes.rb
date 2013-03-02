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

      resources :term_registrations do
        get :mine, :on => :collection, :action => :index, :view => "mine", :as => :my
      end
      
      namespace :import do
        resources :student_imports do
          put :import, :on => :member
        end
      end
    end

    resources :tutors
  end

  namespace :admin do
    # accounts
    resources :students
    resources :student_imports
  end


  get '/:action', :controller => :static, :as => :static
  root :to => 'static#index'
  
end
