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

  resources :shift_details, only: [ :update ]

  resources :projects, only: [ :index, :new, :create, :edit, :update, :destroy ] do
    get "shift_top", to: "shifts#top"

    resources :staffs, only: [ :index, :new, :create, :edit, :update, :destroy ]

    resources :groups, only: [ :index, :new, :create, :edit, :update, :destroy ]

    resources :break_rooms, only: [ :index, :new, :create, :edit, :update, :destroy ]

    resources :shifts, only: [ :new, :create, :edit, :update, :destroy, :show ] do
      member do
        get :confirm # 確定版を表示
        patch :finalize # 完了で確定
        patch :reopen # 編集で再度下書きに戻る
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
