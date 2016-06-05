class EmergenciesController < ApplicationController
	def new		
		page_not_found
	end

	def create
    begin
      emergency = Emergency.new(emergency_params)
      if emergency.save
        render :status => 201, :text => {:emergency => emergency.attributes}.to_json
      else
        render :status => 422, :text => {:message => emergency.errors.messages}.to_json
      end
    rescue => ex
      render :status => 422, :text => {:message => ex.message}.to_json
    end
	end

	def edit
		page_not_found
	end

	def destroy
		page_not_found
	end

	private

	def emergency_params
		params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity)
	end

end
