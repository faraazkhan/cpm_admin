ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    columns do

      column do
        panel "Recent User Requests" do
          table_for(User.pending) do
            column("Name")   {|user| link_to user.name, admin_user_path(user) }
            column :email
            column("Client") {|user| link_to user.client, admin_client_path(user.client)}
            column("Request Received On") { |user| formatted_date(user.created_at) }
            column("Status") { |user| status_tag(user.status, user.status_color) }
          end
        end
      end

      column do
        panel "New Clients" do
          table_for(Client.last(10)) do
            column("Name") { |client| link_to client.name, admin_client_path(client) }
            column("Added On") { |client| formatted_date(client.created_at) }
          end
        end
      end

    end # columns
=begin
Activity Log:
  What are we auditing:   All changes to the User Table, All editable screens
  What do we want to see: Show history on the detail page + Change Log of all changes in the system chronology (most recent 100) configurable
  What do we want to do:  Search the change log
=end
    #section "Recent activity" do
  #table_for PaperTrail::Version.order('id desc').limit(20) do # Use PaperTrail::Version if this throws an error
    #column "Name" do |v| 'Name' end
    ## column "Item" do |v| link_to v.item, [:admin, v.item] end # Uncomment to display as link
    #column "Email" do |v| 'Email' end
    #column "Role" do |v| "role"end
    #column "Client" do |v| 'Client Name' end
    #column "Status" do |v| 'Status' end
    #column "Updated By" do |v| 'Faraaz Khan' end
  #end
#end

  end # content

end # dashboard

