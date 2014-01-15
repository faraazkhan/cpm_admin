ActiveAdmin.register ConfigParameters do
  index do
    column :client_id
    column :enableCM
    column :enablePM
    column :enableDB
    column :enableVM
    column :sasGroup
    column "clientShortName" do |cfg|
      cfg.client.nil? ? cfg.clientShortName : (link_to(cfg.clientShortName, admin_client_path(cfg.client)) )
    end
    column :clientLongName
    column :rptrID
    column :rptrGroup
    column :rptrGroupVM
    column :rptrName
    column :rptrIP
    column :rptrPort
    column :rptrLogin
    column :rptrPass
    column :rptrDB
    column :loadGroup
  end
end
