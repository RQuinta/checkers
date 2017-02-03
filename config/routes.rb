Rails.application.routes.draw do

  root controller: :application, action: :index

  namespace :api, defaults: {format: :json}, constraints: {format: 'json'} do
    resource :partidas, only: [:show, :create, :index]
    resource :movimentos, only: [:show, :create, :index]

    
  end

end
