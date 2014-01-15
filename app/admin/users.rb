ActiveAdmin.register User do
  # Clickable scopes on index views
  scope :internal
  scope :clients
  scope :all

  # Search options available in the Sidebar
  filter :name_or_email, :as => :string
  filter :name
  filter :email

  # Customize the Index page
  index do
    column 'Name' do |user|
      link_to user.name, admin_user_path(user)
    end
    column :email
    column :role
    column 'Client' do |user|
      link_to(user.client, admin_client_path(user.client)) if user.client
    end
    column :status
  end

  # Customize the new and edit forms
  form :partial => "form" #see app/views/admin/_form.html.erb

  # Customize the detail/show page
  show do
    attributes_table do
      row :name
      row :email
      row("Role") { |r| r.role }
      row("Client") {|u| link_to(u.client, admin_client_path(u.client)) if u.client}
      row :status
      row("Change Log") {|u| link_to("View Change History", history_admin_user_path(u))}
    end
  end

  member_action :approve, :method => :get do
    user = User.find(params[:id])
    user.approve!
    redirect_to admin_user_path(user), {:notice => "User Access Request Approved!"}
  end

  member_action :reject, :method => :get do
    user = User.find(params[:id])
    user.reject!
    redirect_to admin_user_path(user), {:notice => "User Access Request Rejected!"}
  end

  member_action :disable, :method => :get do
    user = User.find(params[:id])
    user.disable!
    redirect_to admin_user_path(user), {:notice => "User Account Disabled!"}
  end

  member_action :enable, :method => :get do
    user = User.find(params[:id])
    user.enable!
    redirect_to admin_user_path(user), {:notice => "User Account Enabled!"}
  end

  member_action :unlock, :method => :get do
    user = User.find(params[:id])
    user.unlock!
    redirect_to admin_user_path(user), {:notice => "User Account Unlocked!"}
  end

  member_action :resend_confirmation, :method => :get do
    user = User.find(params[:id])
    user.send_confirmation_instructions
    redirect_to admin_user_path(user), {:notice => "Sent Confirmation Instructions to Registered Email"}
  end

  member_action :history do
    @user= User.find(params[:id])
    @versions = @user.versions
    render "layouts/history"
  end

  member_action :search_history do
    @user = User.find(params[:id])
    @search_term = 'name'
    @versions = @user.versions
    @filtered_versions = @versions.select {|v| v.changeset.keys.include?(@search_term) }
    render "layouts/filtered_history"
  end


  action_item only:[:show] do
    link_to("Approve User Request", approve_admin_user_path(user)) if user.status == 'Pending'
  end
  action_item only:[:show] do
    link_to("Deny User Request", reject_admin_user_path(user)) if user.status == 'Pending'
  end
  action_item only:[:show] do
    link_to("Disable User Account", disable_admin_user_path(user)) if user.active?
  end
  action_item only:[:show] do
    link_to("Activate User Account", enable_admin_user_path(user)) if user.disabled?
  end
  action_item only:[:show] do
    link_to("Unlock User Account", unlock_admin_user_path(user)) if user.locked?
  end
  action_item only:[:show] do
    link_to("Resend Confirmation Email", resend_confirmation_admin_user_path(user)) unless user.confirmed?
  end

  controller do
    # Do not ask for password if user is admin
      def update
        if resource.update_attributes(params[:user])
          redirect_to resource_path(resource), {:notice => 'User Updated'}
        else
          flash[:notice] = "There was a problem"
          redirect_to edit_resource_path(resource) 
        end
      end
    end


end
