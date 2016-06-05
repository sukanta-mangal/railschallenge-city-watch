class ApplicationController < ActionController::Base  
	protect_from_forgery with: :exception

	def page_not_found
		data = File.read(Rails.public_path.join("404.json"))
		render status: :not_found, :text => data.strip.to_s
	end
end
