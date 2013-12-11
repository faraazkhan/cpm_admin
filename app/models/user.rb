class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :disabled
  validates_uniqueness_of :email
  validates_format_of :email, with: /@/
  validates_format_of :password,
    :with => /(?=^.{8,25}$)((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$/,
    :message => "Password should contain: 1 Upper Letter, 1 number, between 8 to 25 characters",
    :on => :create
  validates_length_of :password,
    :minimum => 8,
    :message => "should be at least 8 characters long",
    :on => :create
  search_methods :role_contains

  def is_admin?
    has_role?('Admin')
  end

  def is_hp?
    self.email.match(/(.*)hp\.com/)
  end

  def role_names
    roles.map(&:name).join(', ')
  end

  def self.role_contains(string)
    self.with_role(string)
  end

end
