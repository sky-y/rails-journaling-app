Rails.application.routes.draw do
  resources :notes, only: %i[new]
end
