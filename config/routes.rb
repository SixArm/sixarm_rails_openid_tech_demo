Demo::Application.routes.draw do
  root :to => 'openid#index'
  get "openid" => "openid#index", :as => :openid_root
  post "openid/begin" => "openid#begin", :as => :openid_begin
  get "openid/complete" => "openid#complete", :as => :openid_complete
end
