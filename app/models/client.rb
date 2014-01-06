class Client < ActiveRecord::Base
  attr_accessible :name, :domains_attributes
  has_many :users
  has_many :domains
  accepts_nested_attributes_for :domains, :allow_destroy => true
end
