class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true
  attr_accessible :name, :description
  validates_uniqueness_of :name
  scopify

  def internal?
    %w[Admin Support Viewer].include? self.name
  end
end
