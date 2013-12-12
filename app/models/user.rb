class User < ActiveRecord::Base
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :confirmable
  belongs_to :role
  belongs_to :client

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :disabled, :role_id, :client_id
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
  validate :eligibility_for_role
  scope :internal, where("email like ?", '%@hp.com')
  scope :clients, where("email NOT like ?", '%@hp.com')
  scope :all, where("id is not null")


  def internal?
    email.match(/(.*)\@hp\.com/)
  end

#   ***************** ROLE HELPERS ******************
  def set_role_to(role_name)
    update_attribute(:role_id, Role.find_by_name(role_name).id)
  end

  def has_role?(sym)
    role.to_s.downcase == sym.to_s.downcase
  end

  def is_admin?
    has_role?('Admin')
  end

  private

  def eligibility_for_role
    if role
      if Role.hp_only.include?(role)
        self.internal? ? true : errors.add(:role_id, 'This role is only available to internal HP users')
      else
        self.internal? ? errors.add(:role_id, 'HP users can only be in the Admin or Manager role') : true
      end
    else
      errors.add(:role_id, "can't be blank")
    end
  end

end
