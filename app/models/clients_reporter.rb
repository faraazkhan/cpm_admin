class ClientsReporter < ActiveRecord::Base
  attr_protected []
  belongs_to :client
  belongs_to :reporter
end
