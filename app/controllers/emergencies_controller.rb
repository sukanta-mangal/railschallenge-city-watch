class EmergenciesController < ApplicationController
  before_action :set_emergency, only: [:update,:show]

  def index
    emergencies = Emergency.all

    if emergencies.present?
      full_responders = []
      ['Fire','Police','Medical'].each do |type|
        full_responders += get_full_responders type,"#{type.downcase}_severity"
      end
    end

    if full_responders.blank?
      render :status => 200, :text => {:emergencies => emergencies}.to_json
    else
      render :status => 200, :text => {:full_responses => [full_responders.count, emergencies.count]}.to_json
    end

  end

	def create
    begin
      emergency = Emergency.new(emergency_params)
      if emergency.save
        @exceed_number = false
        all_responders = []
        all_responders << get_responders('Fire', emergency.fire_severity)
        all_responders << get_responders('Police', emergency.police_severity)
        all_responders << get_responders('Medical', emergency.medical_severity)

        if all_responders.present?
          emergency.responders = all_responders.flatten
          emergency.save
        end

        render :status => 201, :text => {:emergency => emergency.attributes.merge(:full_response => !@exceed_number)}.to_json

      else
        render :status => 422, :text => {:message => emergency.errors.messages}.to_json
      end
    rescue => ex
      render :status => 422, :text => {:message => ex.message}.to_json
    end
	end

  def show
    if @emergency.present?
      render :status => 200, :text => {:emergency => @emergency}.to_json
    else
      raise_not_found!
    end

  end

  def update
    begin
      if @emergency.update_attributes(update_emergency_params)
        render :status => 200, :text => {:emergency => @emergency}.to_json
      end
    rescue => ex
      render :status => 422, :text => {:message => ex.message}.to_json
    end
  end

	private

  def set_emergency
    @emergency = Emergency.find_by_code(params[:id])
  end

	def emergency_params
		params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity,:responders)
  end

  def update_emergency_params
    params.require(:emergency).permit( :fire_severity, :police_severity, :medical_severity, :resolved_at,:responders)
  end

  def get_responders type, total_capacity
    responders = Responder.where(:on_duty => true, :type => type).where('capacity <= ?',total_capacity).order('capacity DESC')

    cap_arr = responders.map{|res| res.capacity}
    if cap_arr.sum < total_capacity
      @exceed_number ||= true
      responders_name = responders.pluck(:capacity,:name).to_h.values
    else
      @exceed_number ||= false
      every_combination = (1..cap_arr.length).flat_map { |n| cap_arr.combination(n).to_a }
      sub_arr = every_combination.select { |combination| combination.reduce(:+) == total_capacity }.flatten
      responders_name = responders.where(:capacity => sub_arr).pluck(:capacity,:name).to_h.values
    end
    responders_name
  end

  def get_full_responders type, severity_field
    full_responders = Responder.joins("left outer join emergencies on responders.capacity=emergencies.#{severity_field}").
        where( "responders.type=? and emergencies.resolved_at not ?",type,nil)
  end
end
