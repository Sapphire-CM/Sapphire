Sapphire::Application.routes.draw do

  devise_for :accounts # , skip: [ :registrations ]
  as :user do
    get 'accounts'        => 'accounts#index'
    get 'accounts/:id'    => 'accounts#show', :as => "account"
    delete 'accounts/:id' => 'accounts#destroy'
  end

  resources :courses do
    resources :terms do
      get :meeting

      resources :tutorial_groups do
        get :new_tutor_registration
        get :new_student_registration
        post :create_tutor_registration
        post :create_student_registration
        delete :clear_tutor_registration
      end

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
