class Emergency < ActiveRecord::Base
	validates :fire_severity, presence: true,
            numericality: {
                :only_integer => true,
                :greater_than_or_equal_to => 0}
  validates :police_severity, presence: true,
            numericality: {
                :only_integer => true,
                :greater_than_or_equal_to => 0}
  validates :medical_severity, presence: true,
            numericality: {
                :only_integer => true,
                :greater_than_or_equal_to => 0}
  validates :code, presence: true, uniqueness: true
end