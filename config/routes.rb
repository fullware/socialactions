ActionController::Routing::Routes.draw do |map|
  map.resources :api_keys

  map.resources :sites

  map.resources :action_types

  map.resources :action_sources

  map.resources :users

  map.resource :login

  
  map.namespace :shorturl do |shorturl|
    shorturl.resources :redirects, :collection => {:slug => :get}
    shorturl.resources :logs, :collection => {:hits => :get, :referrers => :get}
  end
  
  map.connect '/s/:slug', :controller => 'shorturl/redirects', :action => 'url'
  
  map.connect '/shorturl/logs/:slug/hits', :controller => 'shorturl/logs', :action => 'hits'
  map.connect '/shorturl/logs/:slug/hits.:format', :controller => 'shorturl/logs', :action => 'hits'
  
  map.connect '/shorturl/logs/:slug/referrers', :controller => 'shorturl/logs', :action => 'referrers'
  map.connect '/shorturl/logs/:slug/referrers.:format', :controller => 'shorturl/logs', :action => 'referrers'

  map.resources :actions, :tags, :map, :donations

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)
  map.random '/random', :controller => 'actions', :action => 'random'
  map.access_denied '/access_denied', :controller => 'api_keys', :action => 'access_denied'
  map.access_denied '/access_denied.:format', :controller => 'api_keys', :action => 'access_denied'
  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect '', :controller => 'actions', :action => 'index'
end
