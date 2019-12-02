Rails.application.routes.draw do
  mount Spree::Core::Engine, at: '/'
  Spree::Core::Engine.routes.draw do
    namespace :admin do
      get '/import_csv' => 'products#import_csv'
      post '/upload_csv' => 'products#upload_csv'  
    end
  end
end

