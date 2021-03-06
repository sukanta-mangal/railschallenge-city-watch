class Responder < ActiveRecord::Base
  self.inheritance_column = nil
  validates :capacity, presence: true, numericality: {only_integer: true,
                                                      greater_than_or_equal_to: 1,
                                                      less_than_or_equal_to: 5,
                                                      message: "is not included in the list"}
  validates :name, uniqueness: true, presence: true
  validates :type, presence: true

  scope :fire_type, -> {where(:type => 'Fire')}
  scope :police_type, -> {where(:type => 'Police')}
  scope :medical_type, -> {where(:type => 'Medical')}
end
