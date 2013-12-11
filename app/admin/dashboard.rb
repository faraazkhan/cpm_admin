ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    #div :class => "blank_slate_container", :id => "dashboard_default_message" do
    #span :class => "blank_slate" do
    #span I18n.t("active_admin.dashboard_welcome.welcome")
    #small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #end
    #end

    columns do

      column do
        panel "Recent User Requests" do
          table_for(User.last(5)) do
            column("Name")   {|user| link_to user.name, admin_user_path(user) }
            column :email
            column("Request Received On") { |user| user.created_at.to_date.strftime('%m/%d/%Y') }
            column("Status") { |user| status_tag('active', :ok) }
          end
        end
      end

      column do
        panel "Info" do
          para "Welcome to ActiveAdmin."
        end
      end

    end # columns

  end # content
end # dashboard

