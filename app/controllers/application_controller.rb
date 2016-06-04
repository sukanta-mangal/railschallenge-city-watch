class ApplicationController < ActionController::Base  
	protect_from_forgery with: :exception

	def page_not_found
		render status: :not_found, :text => '{"message": "page not found"}'
	end
end
