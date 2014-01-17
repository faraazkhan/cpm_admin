class User < ActiveRecord::Base
  has_paper_trail
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable
  belongs_to :role
  belongs_to :client
  has_many :audit_logs, :as => :item

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :disabled, :role_id, :client_id, :status, :approved
  validates_uniqueness_of :email
  validates_presence_of :name
  validates_format_of :email, with: /@/
  validates_format_of :password,
    :with => /(?=^.{8,25}$)((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$/,
    :message => "Password should contain: 1 Upper Letter, 1 number, between 8 to 25 characters",
    :on => :create, :if => :enforce_password_requirement
  validates_length_of :password,
    :minimum => 8,
    :message => "should be at least 8 characters long",
    :on => :create, :if => :enforce_password_requirement
  validate :eligibility_for_role

  #Scopes #TODO: make these class methods
  scope :internal, where("email like ?", '%@hp.com')
  scope :clients, where("email NOT like ?", '%@hp.com')
  scope :all, where("id is not null")
  scope :pending, where("status = 'Pending'")
  scope :active, where("status = 'Active'")
  scope :locked, where("status = 'Locked'")
  before_save :set_status, :update_audit_log
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

  def approve!
    self.approved = true
    self.save!
  end

  def reject!
    self.destroy
  end

  def disable!
    self.disabled = true
    self.save!
  end

  def enable!
    self.disabled = false
    self.save!
  end

  def unlock!
    self.locked_at = nil
    self.save!
  end

  def locked?
    locked_at.present?
  end

  def admin_approved?
    internal? || approved?
  end

  def active?
    status == 'Active'
  end

  def audits
    self.audit_logs
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

  def set_status
    puts 'Called Set Status'
    self.status = calculate_status
  end

  def calculate_status
    #Unconfirmed: Waiting on user to confirm email access. Show message. No admin action required
    #Pending: Waiting for admin approval. Show message saying the same (Approve/Deny)
    #Active: They have intended access
    #Locked: Account locked. Admin must unlock. Show message. Create admin section for all locked account. Admin should be able to unlock
    #Disabled: Black List; also used for disabled/deactivated accounts. Admin can approve/remove users from here as well.
    return 'Unconfirmed' unless confirmed_at
    return 'Locked' if locked?
    return 'Disabled' if disabled?
    return 'Pending' unless admin_approved?
    'Active'
  end




  def identify_role_and_client
    if internal?
      self.approved = true
      self.role_id = Role.find_by_name('Manager').id unless self.role
    else
      self.role_id = Role.find_by_name('Client').id
      self.client_id = Client.for(self).try(:id)
    end
  end

  def enforce_password_requirement
    false
  end

  def update_audit_log
    if self.changed?
      self.attributes.each do |attr, value|
        method = "#{attr}_changed?".to_sym
        change = self.send(method)
        change_method = "#{attr}_change".to_sym
        old_value, new_value = self.send(change_method)
        if change
          AuditLog.create(:item_type => 'User', :item_id => self.id, :item_attribute => attr, :previous_value => old_value, :new_value => new_value, :performed_by => User.last.id, :created_at => Time.now)
        end
      end
    end
  end

end
