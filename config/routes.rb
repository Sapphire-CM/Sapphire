Sapphire::Application.routes.draw do
  devise_for :accounts, skip: :registration

  resources :accounts, except: [:show, :new, :create] do
    get :change_password, on: :member
    patch :update_password, on: :member
  end

  resources :courses, except: [:show]

  resources :terms do
    get :new_lecturer_registration
    post :create_lecturer_registration
    delete :clear_lecturer_registration

    get :grading_scale
    post :update_grading_scale
    get :points_overview
  end

  resources :tutorial_groups do
    get :new_tutor_registration
    post :create_tutor_registration
    delete :clear_tutor_registration

    get :points_overview

    resources :grading_reviews, only: [:index, :show]

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

  namespace :import do
    resources :student_imports do
      get :full_mapping_table, on: :member
      get :results, on: :member
    end
  end

  resources :submissions, only: :show do
    resource :evaluation, controller: 'submission_evaluations', except: [:destroy]
  end

  resources :submission_viewers

  resources :submission_evaluations, except: [:destroy]

  resources :submission_assets, only: [:show, :new, :create]

  resources :single_evaluations

################################################################################

  root to: 'courses#index'

  get 'submission_viewers/show'

end
