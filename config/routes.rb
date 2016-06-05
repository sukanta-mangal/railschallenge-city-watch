Rails.application.routes.draw do
	resources :emergencies, only:[:create,:index,:update,:show]
  resources :responders,only:[:create,:index,:update,:show]
  match '*unmatched_route', :to => 'application#raise_not_found!', :via => :all
end
