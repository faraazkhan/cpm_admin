class Client < ActiveRecord::Base
  attr_accessible :name, :domains_attributes
  has_many :users
  has_many :domains
  has_many :clients_reporters
  has_many :reporters, :through => :clients_reporters
  has_and_belongs_to_many :services
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

  def service_groups
    self.services.collect(&:service_group)
  end

  def services_by_group
    services.group_by(&:service_group)
  end

end
