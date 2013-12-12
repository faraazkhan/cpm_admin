class Domain < ActiveRecord::Base
  attr_accessible :client_id, :name
  belongs_to :client
end
