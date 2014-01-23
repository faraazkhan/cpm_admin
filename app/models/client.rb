class Client < ActiveRecord::Base
  attr_accessible :name, :domains_attributes
  has_many :users
  has_many :domains
  has_and_belongs_to_many :reporters
  accepts_nested_attributes_for :domains, :allow_destroy => true

  def self.for(user)
    email = user.email
    domain = email.gsub(/^(.*)@/,'').chomp
    domain = Domain.find_by_name(domain)
    domain.try(:client)
  end

  def to_s
    self.name
  end

end
