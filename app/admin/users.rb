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
  end

  # Customize the new and edit forms
  form :partial => "form" #see app/views/admin/_form.html.erb

  # Customize the detail/show page
  show do
    attributes_table do
      row :name
      row :email
      row("Role") { |r| r.role }
    end
  end
end
