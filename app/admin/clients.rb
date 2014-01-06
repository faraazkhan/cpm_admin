ActiveAdmin.register Client do
  # Search options available in the Sidebar
  filter :name
  index do
    column 'Name' do |client|
      link_to client.name, admin_client_path(client)
    end
    default_actions
  end


  form do |f|
      f.inputs "Client" do
        f.input :name
      end
      f.inputs do
        f.has_many :domains, :allow_destroy => true, :heading => 'Domains' do |cf|
          cf.input :name
        end
      end
      f.actions
    end

  show do 
    attributes_table do
      row :name
    end

    panel "Accepted Domains" do
      ul do
        client.domains.each do |dom|
          li dom.name
        end
      end
    end
  end

end

