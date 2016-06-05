class ApplicationController < ActionController::Base  
	protect_from_forgery with: :exception
  rescue_from ActionController::RoutingError, with: lambda { |exception| render_error 404 }

  def raise_not_found!
    raise ActionController::RoutingError.new("No route matches #{params[:unmatched_route]}")
  end
  def render_error(status)
    data = File.read(Rails.public_path.join("404.json"))
    render status: status, :text => data.strip.to_s
  end

end
