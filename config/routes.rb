Attachinary::Engine.routes.draw do
  get '/cors' => 'cors#show', format: 'json', as: 'cors'
end
