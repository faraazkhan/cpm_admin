ActiveAdmin.register User do
  filter :name_or_email, :as => :string
  filter :name
  filter :email
  filter :role, :as => :string #see def self.by_role_contains in app/models/user.rb
  index do
    column 'Name' do |user|
      link_to user.name, admin_user_path(user)
    end
    column :email
    column "Roles" do |user|
      user.role_names
    end
  end

  form :partial => "form" #see app/views/admin/_form.html.erb
  show do
    attributes_table do
      row :name
      row :email
      row("Roles") { |r| r.role_names }
    end
    #render "show" # see app/views/admin/_show.html.erb
  end
end
