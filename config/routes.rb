require 'sidekiq/web'

Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  devise_for :accounts, skip: :registration

  resources :accounts do
    resources :email_addresses, except: [:show]
  end

  resource :impersonation, only: [:create, :destroy]

  resources :courses, except: [:show]

  resources :terms, except: [:index] do
    member do
      get :points_overview
    end

    resources :accounts, only: :index, controller: "terms/accounts"

    resources :students

    resources :grading_scales, only: [:index] do
      put :update, action: :bulk_update, on: :collection
    end

    resources :exercises, except: [:show] do
      resources :services, only: [:index, :edit, :update]
    end

    resources :staff, except: [:show, :edit, :update] do
      post :search, on: :collection
    end

    resources :imports, except: [:index, :edit] do
      get :file, on: :member
      get :full_mapping_table, on: :member
      get :results, on: :member
    end

    resources :exports, except: [:show, :edit, :update] do
      get :download, on: :member
    end

    resources :tutorial_groups do
      get :points_overview, on: :member
    end

    resources :student_groups do
      post :search_students, on: :collection
    end

    resources :grading_reviews, only: [:index, :show]
    resources :results, only: [:index, :show], controller: :student_results
    resources :events, only: [:index]

    resource :welcome_notifications, only: :create 
    resource :submissions_statistics, controller: "submissions_disk_usage_statistics", only: :show
  end

  resources :tutorial_groups

  resources :exercises, except: [:index] do
    resources :rating_groups, except: :show do
      post :update_position, on: :member
      resources :ratings, except: [:index, :show] do
        post :update_position, on: :member
      end
    end

    resource :submission, only: [:show, :new, :create], as: :student_submission, controller: "student_submissions"
    resource :bulk_grading, only: [:new, :create] do
      resources :subjects, controller: "bulk_gradings/subjects", only: :index
    end

    resources :submissions, only: :index, controller: "staff_submissions"

    resources :result_publications, only: :index do
      member do
        put :publish
        put :conceal
      end

      collection do
        put :publish_all
        put :conceal_all
      end
    end
  end

  resources :submission_assets, only: [:show, :destroy]
  resources :submission_viewers, only: [:show]

  resources :evaluations, only: :update do
    resources :explanations, module: :evaluations
  end

  resources :evaluation_groups, only: :update
  resources :submission_evaluations, controller: :submission_evaluations, only: :show do
    resources :feedback, module: :submission_evaluations
    resources :internal_notes, module: :submission_evaluations
  end

  resources :submissions, only: [:show, :edit, :update] do
    member do
      get "blob(/*path)", controller: :submission_blob, action: :show, as: :blob
      get "tree(/*path)", controller: :submission_tree, action: :show, as: :tree
      get "directory(/*path)", controller: :submission_tree, action: :directory, as: :tree_directory
      delete "tree(/*path)", controller: :submission_tree, action: :destroy
    end
    resources :students, controller: "submissions/students"
    resource :folder, controller: :submission_folders, only: [:show, :new, :create]
    resource :upload, controller: :submission_uploads, only: [:new, :create]
  end

  authenticate :account, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/rails/emails"
  end

  root to: 'courses#index'
end
