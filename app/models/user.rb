class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable
  belongs_to :role
  belongs_to :client

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :disabled, :role_id, :client_id, :status, :approved
  validates_uniqueness_of :email
  validates_presence_of :name
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

  #Scopes #TODO: make these class methods
  scope :internal, where("email like ?", '%@hp.com')
  scope :clients, where("email NOT like ?", '%@hp.com')
  scope :all, where("id is not null")
  scope :pending, where("status = 'Pending'")
  scope :active, where("status = 'Active'")
  scope :locked, where("status = 'Locked'")
  before_save :calculate_status
  before_create :identify_role_and_client


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

  def status_color
    case self.status
    when 'Active'
      :green
    when 'Locked'
      :red
    when 'Pending'
      :orange
    end
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
      errors.add(:role_id, "can't be blank") unless self.new_record?
    end
  end

  def calculate_status
    if self.new_record?
      self.status = internal? ?  'Active' : 'Pending'
    elsif self.locked_at_changed?
      self.status = 'Locked' if self.locked_at #update status to locked when account is locked
      if (self.approved? || self.internal?) #update status to either 'Active' or 'Pending' when account is unlocked
        self.status = 'Active'
      else
        self.status = 'Pending'
      end
    end
  end

  def identify_role_and_client
    if internal?
      self.approved = true
      self.role_id = Role.find_by_name('Manager').id
    else
      self.role_id = Role.find_by_name('Client').id
      self.client_id = Client.for(self).try(:id)
    end
  end

end
