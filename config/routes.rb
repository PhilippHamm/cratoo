Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  resources :favorites, only: [:new, :create, :show, :delete] do
    resources :playlists, only: [:new, :create]
  end
  resources :songs, only: [:show, :new, :create, :edit, :update, :delete]
  resources :styles, only: [:show, :new, :create, :edit, :update, :delete]
  resources :genres, only: [:show, :new, :create, :edit, :update, :delete]
  resources :songs, only: [:show, :new, :create, :edit, :update, :delete]
  resources :publishing_countries, only: [:show, :new, :create, :edit, :update, :delete]
  resources :artists, only: [:show, :new, :create, :edit, :update, :delete]
  resources :playlists, only: [:show, :edit, :update, :delete]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
