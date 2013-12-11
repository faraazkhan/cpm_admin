# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Role.delete_all
roles = {
  :admin => 'An HP internal role that has permissions to view/edit/delete all pages in the application', 
  :support => 'An HP internal role that has permission to view all admin pages and client reports',
  :viewer => 'An HP internal role that has permission to view all pages for all clients',
  :client => 'An external role that only has permissions to view reports for a specific client'
}
roles.each do |name, description|
  Role.create!(:name => name.to_s.titleize, :description => description)
end
User.delete_all
user = User.create!(:name => 'CPM Administrator', :email => 'cpm_admin@hp.com', :password => 'Admin123', :password_confirmation => 'Admin123')
user.confirmed_at = Time.now
user.save!
user.add_role('Admin')

