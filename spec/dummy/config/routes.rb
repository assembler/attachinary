Rails.application.routes.draw do

  mount Attachinary::Engine => "/attachinary", :as => 'attachinary_engine'

  resources :notes
end
