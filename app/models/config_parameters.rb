class ConfigParameters < ActiveRecord::Base
  set_table_name "vw_cfgParamsDW"
  attr_accessible :client_id,
    :enableCM,
    :enablePM,
    :enableDB,
    :enableVM,
    :sasGroup,
    :clientShortName,
    :clientLongName,
    :rptrID,
    :rptrGroup,
    :rptrGroupVM,
    :rptrName,
    :rptrIP,
    :rptrPort,
    :rptrLogin,
    :rptrPass,
    :rptrDB,
    :loadGroup
  self.primary_key = :config_parameter_id


  def client
    Client.find_by_client_id(self.client_id)
  end
end
