Sapphire::Application.routes.draw do
  get "submission_viewers/show"
  devise_for :accounts, skip: :registration

  resources :accounts, except: [:new, :show] do
    get :change_password, on: :member
    patch :update_password, on: :member
  end

  resources :courses

  resources :submission_assets, only: [:show, :new, :create]

  resources :terms do
    get :new_lecturer_registration
    post :create_lecturer_registration
    delete :clear_lecturer_registration

    post :update_grading_scale
    get :points_overview
  end

  resources :submissions, only: :show do
    resource :evaluation, controller: 'submission_evaluations'
  end

  resources :tutorial_groups do
    get :new_tutor_registration
    post :create_tutor_registration
    delete :clear_tutor_registration

    get :points_overview

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

    resources :submissions
  end

  resources :single_evaluations
  resources :submission_viewers

  resources :submission_evaluations


  namespace :import do
    resources :student_imports do
      get :full_mapping_table, on: :member
      get :results, on: :member
    end
  end

  root to: 'courses#index'

end
