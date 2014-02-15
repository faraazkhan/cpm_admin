class EnvVar < ActiveRecord::Base
  attr_accessible :description, :name, :value

  def self.app_title
    find_by_name('app_title').try(:value)
  end
end
