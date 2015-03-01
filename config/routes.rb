require 'sidekiq/web'

Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  devise_for :accounts, skip: :registration

  resources :accounts, except: [:new, :create] do
    resources :email_addresses, except: [:show]
  end

  resources :courses, except: [:show]

  resources :terms, except: [:index] do
    get :points_overview, on: :member

    resource :grading_scale, only: [:edit, :update]

    resources :exercises, except: [:show] do
      resources :services, only: [:index, :edit, :update]
    end

    resources :staff, except: [:show, :edit, :update] do
      post :search, on: :collection
    end

    resources :students, only: [:index, :show]

    resources :imports, except: [:index, :edit] do
      get :full_mapping_table, on: :member
      get :results, on: :member
    end

    resources :exports, except: [:show, :edit, :update] do
      get :download, on: :member
    end

    resources :tutorial_groups do
      get :points_overview, on: :member

      resources :student_groups do
        post :search_students, on: :collection
      end
    end

    resources :grading_reviews, only: [:index, :show]
    resources :results, only: [:index, :show], controller: :student_results
  end

  resources :tutorial_groups

  resources :exercises, except: [:show, :index] do
    resources :rating_groups, except: :show do
      post :update_position, on: :member
      resources :ratings, except: [:index, :show] do
        post :update_position, on: :member
      end
    end

    resource :submission, only: [:show, :create, :update], as: :student_submission, controller: "student_submissions"

    resources :submissions, controller: "staff_submissions"
    resources :result_publications, only: [:index, :update]
    resource :results, controller: 'student_results', as: :student_results, only: :show
  end

  resources :submission_viewers, only: [:show]
  resources :submission_assets, only: [:show, :new, :create]
  resources :single_evaluations, only: [:show, :update]

  authenticate :account, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/rails/emails"
  end

  root to: 'courses#index'
end
