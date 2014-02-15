namespace :db do
  desc "Adds some sample data to the app"
  task :sample_data => :environment do
    # ******* SAMPLE DATA **************
    Client.delete_all
    clients = %w[MyClient AnotherClient Client3]
    clients.each do |client|
      Client.create!(:name => client)
    end

    Domain.delete_all
    domains = {
      :my_client => %w[myclient.com anotherdomainformyclient.com],
      :another_client => %w[anotherclient.com],
      :client3 => %w[client3.com]
    }
    domains.each do |client, doms|
      doms.each do |dom|
        Domain.create!(:client_id => Client.find_by_name(client.to_s.camelize).id, :name => dom)
      end
    end

    User.delete_all
    admin = User.create!(:name => 'CPM Administrator', :email => 'cpm_admin@hp.com', :password => 'Admin123', :password_confirmation => 'Admin123', :role_id => Role.find_by_name('Admin').id)
    client = User.create!(:name => 'CPM Client', :email => 'client@myclient.com', :password => 'Client123', :password_confirmation => 'Client123', :role_id => Role.find_by_name('Client').id, :client_id => Client.find_by_name('MyClient').id)
    manager = User.create!(:name => 'CPM Manager', :email => 'cpm_manager@hp.com', :password => 'Manager123', :password_confirmation => 'Manager123', :role_id => Role.find_by_name('Manager').id)

    admin.confirmed_at = client.confirmed_at = manager.confirmed_at =  Time.now
    admin.save!
    client.save!
    manager.save!
    client.services << Service.first
  end

end
