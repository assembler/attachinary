Rails.application.routes.draw do
  mount Attachinary::Engine => "/attachinary"
  resources :notes
end
