class Role < ActiveRecord::Base
  attr_accessible :description, :name
  has_many :users

  def to_s
    self.name
  end

  def self.hp_only
    %w[Admin Manager].collect do |name|
      Role.find_by_name name
    end
  end
end
