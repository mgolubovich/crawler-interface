Rails.application.routes.draw do
  devise_for :users
  resources :sources, :cartridges, :tenders

  root :to => 'default#index'
  get '/error', :to => 'default#error'

  get '/api/switch/:model/:id/:active/', to: 'api#switch'
  get '/api/default-tender-values', to: 'api#default_tender_values'
  get '/api/check-code-source/:source_id/:code_by_source', to: 'api#check_code_source'
  get '/api/selector-types', to: 'api#selector_types'
  get '/api/selector/:id/', to: 'api#selector'


  get '/moderation/', to: 'moderation#next'
  get '/moderation/next/', to: 'moderation#next'
  get '/moderation/prev/', to: 'moderation#prev'
  get '/moderation/prev/:id', to: 'moderation#prev'
  get '/moderation/list/', to: 'moderation#list'
  get '/moderation/process/:id/:type/', to: 'moderation#moderate'


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
