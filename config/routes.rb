Rails.application.routes.draw do
  root to: 'pages#home'

  resources :plans, only: [:index] do
    collection do
      post :remove
      post :add
      get :refresh
      get :export
    end
  end
end
