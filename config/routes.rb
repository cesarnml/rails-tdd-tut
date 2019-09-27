Rails.application.routes.draw do
  resources :articles do
    resources :comments, only: %i[index create]
  end

  post 'login', to: 'access_tokens#create'
  delete 'logout', to: 'access_tokens#destroy'
end
