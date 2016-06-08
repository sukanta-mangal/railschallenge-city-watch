class RespondersController < ApplicationController
  before_action :set_responder, only: [:update, :show]

  def index
    @responders = Responder.all

    if @responders.blank?
      render :status => 200, :text => {:responders => @responders}.to_json
    else
      if params[:show] == 'capacity'
        capacity = {}

        %w[Fire Police Medical].each do |emergency_type|
          capacity[emergency_type] = get_capacity_available(emergency_type)
        end

        render :status => 200, :text => {:capacity => capacity}.to_json
      else
        render :status => 200, :text => {:responders => @responders.map{|resp| resp.attributes.except("id","created_at","updated_at")}}.to_json
      end
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

  def get_capacity_available type
    cap_arr = []
    emergencies = Emergency.where("resolved_at is ? and #{type.downcase}_severity > ?",nil,0)
    filter_type = @responders.send("#{type.downcase}_type").order('capacity asc')
    total_capacity = filter_type.sum(:capacity)
    total_avail_to_respond = total_capacity
    unless emergencies.present?
      total_on_duty = filter_type.where(:on_duty => true).sum(:capacity)
      total_ready_to_respond = total_on_duty
    else
      assigned_responder = []
      total_responded_capacity = 0
      emergencies.each do |emergency|
        responded_responder = filter_type.where("on_duty = ? and
                              capacity >= ?", true, emergency.send("#{type.downcase}_severity")).where.not(:id => assigned_responder).first
        if responded_responder.present?
          total_avail_to_respond -= responded_responder.capacity
        else
          responded_responder = filter_type.where("on_duty = ? and
                              capacity < ?", true, emergency.send("#{type.downcase}_severity")).where.not(:id => assigned_responder).last
          total_avail_to_respond -= responded_responder.capacity
        end
        assigned_responder << responded_responder.id
        total_responded_capacity += responded_responder.capacity
      end

      total_on_duty = filter_type.where(:on_duty => true).sum(:capacity)
      total_ready_to_respond = total_on_duty - total_responded_capacity
    end
    #binding.pry
    cap_arr << total_capacity << total_avail_to_respond << total_on_duty << total_ready_to_respond
  end

end
