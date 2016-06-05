class RespondersController < ApplicationController
  def create
    begin
    rescue
    end
  end

  private

  def responder_params
    params.require(:responder).permit(:type, :name, :capacity, :on_duty)
  end
end
