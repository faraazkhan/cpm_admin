class AuditLog < ActiveRecord::Base
 attr_protected []
 belongs_to :item, :polymorphic => true

 def performed_by_name
   User.find(self.performed_by) rescue 'Unknown User'
 end
end
