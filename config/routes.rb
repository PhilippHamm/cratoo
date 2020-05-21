Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }
  root to: 'pages#home'
  resources :users, only: [:show, :edit, :update, :delete]
  resources :songs, only: [:create, :delete]
  resources :styles, only: [:create, :delete]
  resources :genres, only: [:create, :delete]
  resources :publishing_countries, only: [:create, :delete]
  resources :artists, only: [:create, :delete]
  resources :playlists, only: [:index, :new, :create, :show, :edit, :update, :delete]
  resources :playlist_songs, only: [:create, :delete]
  resources :data, only: [:index, :new, :create]
  get 'data/:id', to: 'data#save', as: :save
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
