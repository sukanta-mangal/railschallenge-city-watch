class RespondersController < ApplicationController
  before_action :set_responder, only: [:update, :show]

  def index
    responders = Responder.all

    if responders.blank?
      render :status => 200, :text => {:responders => responders}.to_json
    else
      render :status => 200, :text => {:responders => responders.map{|resp| resp.attributes.except("id","created_at","updated_at")}}.to_json
    end

  end

  def create
    begin
      responder = Responder.new(responder_params)
      if responder.save
        data_hash = {
          :emergency_code => responder.emergency_code,
          :type => responder.type,
          :name => responder.name,
          :capacity => responder.capacity,
          :on_duty => responder.on_duty
        }
        render :status => 201, :text => {:responder => responder.attributes.except("id","created_at","updated_at")}.to_json
      else
        render :status => 422, :text => {:message => responder.errors.messages}.to_json
      end
    rescue => ex
      render :status => 422, :text => {:message => ex.message}.to_json
    end
  end

  def show
    if @responder.present?
      render :status => 200, :text => {:responder => @responder.attributes.except("id","created_at","updated_at")}.to_json
    else
      raise_not_found!
    end
  end

  def update
    if @responder.present?
      begin
        if @responder.update_attributes(update_responder_params)
          render :status => 200, :text => {:responder => @responder}.to_json
        end
      rescue => ex
        render :status => 422, :text => {:message => ex.message}.to_json
      end
    end
  end

  private

  def responder_params
    params.require(:responder).permit(:type, :name, :capacity)
  end

  def update_responder_params
    params.require(:responder).permit(:on_duty)
  end

  def set_responder
    @responder = Responder.find_by_name(params[:id])
  end
end
