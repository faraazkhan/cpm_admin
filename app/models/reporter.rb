class Reporter < ActiveRecord::Base
  attr_accessible :database_name, :ip, :load_group, :login, :name, :password, :port, :reporter_num
  #reporter_num is the external look up id for reporters. 
  #Created because we did not want to repurpose the id field
  has_many :clients_reporters
  has_many :reporters, :through => :clients_reporters
end
