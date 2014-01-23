class Reporter < ActiveRecord::Base
  attr_accessible :database_name, :ip, :load_group, :login, :name, :password, :port
  has_and_belongs_to_many :clients
end
