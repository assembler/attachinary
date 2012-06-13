Rails.application.routes.draw do
  mount Attachinary::Engine => "/attachinary"
  resources :notes
  root to: 'notes#index'
end
