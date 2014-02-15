require 'csv'

def data_for(klass_name)
  seed_data_files_path = File.join(File.dirname(__FILE__), 'seed_data')
  klass = klass_name.constantize
  klass.delete_all
  filename = klass.table_name + '.csv'
  file = File.join(seed_data_files_path, filename)
  CSV.read(file, :headers => true)
end

#Create Roles
#Role.delete_all
#roles_file = File.join(seed_data_files_path, 'roles.csv')
#roles = CSV.read(roles_file, :headers => true)
roles = data_for('Role')
roles.each do |role|
  Role.create!(:name => role['name'].to_s.titleize, :description => role['description'])
end

#Create Service Groups
service_groups = data_for('ServiceGroup')
service_groups.each do |group|
  ServiceGroup.create!(:name => group['name'], :description => group['description'])
end

#Create Services
#Service.delete_all
#services_file = File.join(seed_data_files_path, 'services.csv')
#services = CSV.read(services_file, :headers => true)
services = data_for("Service")
services.each do |service|
  Service.create!(:name => service['name'], :description => service['description'], :service_group_id => ServiceGroup.find_by_name(service['service_group_name']).id)
end

#ServiceGroup.delete_all
#service_groups_file = File.join(seed_data_files_path, 'service_groups.csv')
#service_groups = CSV.read(service_groups_file, :headers => true)



