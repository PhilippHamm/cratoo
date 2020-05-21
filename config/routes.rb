Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }
  root to: 'pages#home'
  get 'suggested_songs', to: 'pages#suggested_songs', as: :suggested_songs
  resources :users, only: [:show, :edit, :update, :delete]
  resources :songs, only: [:create, :delete, :index]
  resources :styles, only: [:create, :delete]
  resources :genres, only: [:create, :delete]
  resources :publishing_countries, only: [:create, :delete]
  resources :artists, only: [:create, :delete]
  resources :playlists, only: [:index, :new, :create, :show, :edit, :update, :delete]
  resources :playlist_songs, only: [:create, :delete]
  resources :data, only: [:index, :new, :create]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
