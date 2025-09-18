Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  # トップページをログイン画面に設定
  devise_scope :user do
    root to: "devise/sessions#new"
  end

  resources :projects, only: [ :index, :new, :create, :edit, :update, :destroy ] do
    get "shift_top", to: "shifts#top"

    resources :shifts, only: [ :new, :create, :edit, :update, :destroy ] do
      # PDF表示画面のためのURL作成
      member do
        get :pdf
      end

      collection do
        get :fetch # 月ごとのシフトを返す(Ajaxでシフト一覧を変えるエンドポイント)
        get :step1 # STEP1入力画面
        post :step1_create
        get :step2 # STEP2入力画面
        post :step2_create
      end
    end
  end
end
