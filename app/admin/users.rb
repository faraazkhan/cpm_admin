ActiveAdmin.register User do
  scope :internal
  scope :clients
  scope :all
  filter :name_or_email, :as => :string
  filter :name
  filter :email
  #filter :role, :as => :string #see def self.by_role_contains in app/models/user.rb
  index do
    column 'Name' do |user|
      link_to user.name, admin_user_path(user)
    end
    column :email
    column :role
  end

  form :partial => "form" #see app/views/admin/_form.html.erb
  show do
    attributes_table do
      row :name
      row :email
      row("Role") { |r| r.role }
    end
    #render "show" # see app/views/admin/_show.html.erb
  end
end
