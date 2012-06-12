Attachinary::Engine.routes.draw do

  get '/cors' => 'cors#show', format: 'json', as: 'cors'
  get '/callback' => 'files#callback', format: 'json', as: 'callback'

end
