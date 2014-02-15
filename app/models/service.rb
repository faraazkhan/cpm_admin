class Service < ActiveRecord::Base
  attr_accessible :description, :name, :service_group_id
  has_and_belongs_to_many :clients
  belongs_to :service_group
end
