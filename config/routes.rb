Sapphire::Application.routes.draw do

  resources :submission_evaluations

  devise_for :accounts
  as :user do
    get 'accounts'          => 'accounts#index'
    get 'accounts/:id'      => 'accounts#show', as: "account"
    get 'accounts/:id/edit' => 'accounts#edit', as: "edit_account"
    put 'accounts/:id'      => 'accounts#update'
  end

  resources :courses

  resources :terms do
    get :new_lecturer_registration
    post :create_lecturer_registration
    delete :clear_lecturer_registration

    resources :submissions do
      resource :evaluation, controller: 'submission_evaluations'
    end

    post :update_grading_scale

    get :meeting

    resources :tutorial_groups do
      get :new_tutor_registration
      post :create_tutor_registration
      delete :clear_tutor_registration

      resources :student_groups do
        get :new_student_registration
        post :create_student_registration
      end
    end

    resources :exercises do
      resources :rating_groups, except: [:index, :show] do
        post :update_position, on: :member
        resources :ratings, except: [:index, :show] do
          post :update_position, on: :member
        end
      end

      resource :evaluation, controller: 'exercise_evaluations_table'

    end

    namespace :import do
      resources :student_imports do
        get :full_mapping_table, on: :member
        get :results, on: :member
      end
    end
  end

  get '/:action', controller: :static, as: :static
  root to: 'static#index'

end
