Demo::Application.routes.draw do
  root :to => 'openid#index'
  get "openid" => "openid#index"
  post "openid/foo" => "openid#foo"
  post "openid/begin" => "openid#begin"
  get "openid/complete" => "openid#create"
end
