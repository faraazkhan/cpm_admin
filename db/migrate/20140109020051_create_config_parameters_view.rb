class CreateConfigParametersView < ActiveRecord::Migration
  def change
    if Rails.env.test? 
      #create table
      create_table(:vw_cfgParamsDW) do |t|
        [
          :client_id,
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
          :loadGroup,
          :config_parameter_id].each do |attribute|
            t.string attribute
          end
      end
    else
      sql = <<-QUERY
            USE [cpm_admin]
            GO

            /****** Object:  View [dbo].[vw_paramsDW]    Script Date: 01/08/2014 21:07:59 ******/
            IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_paramsDW]'))
            DROP VIEW [dbo].[vw_paramsDW]
            GO

            USE [cpm_admin]
            GO

            /****** Object:  View [dbo].[vw_paramsDW]    Script Date: 01/08/2014 21:07:59 ******/
            SET ANSI_NULLS ON
            GO

            SET QUOTED_IDENTIFIER ON
            GO


            CREATE VIEW [dbo].[vw_paramsDW]
            AS

            SELECT
              R.loadGroup as rptrLoadGroup
             ,R.name as rptrName
             ,C.shortName as clientShortName
             --,CR.clientID
             ,C.sasGroup as clientSasGroup
             --,C.enableCM
             ,CR.rptrGroupCPM
             --,C.enableDB
             ,CR.rptrGroupSQL
             ,CR.rptrGroupORA
             --,C.enableVM
             ,CR.rptrGroupVMW
             ,CR.rptrID
             ,R.ip as rptrIP
             ,R.port as rptrPort
             ,R.login as rptrLogin
             ,R.pass as rptrPass
             ,R.db as rptrDB
            FROM
             clients AS C INNER JOIN
             clients_reporters AS CR ON CR.clientID = C.id INNER JOIN
             reporters AS R ON CR.rptrID = R.id
            WHERE
             R.loadGroup > 0
            --ORDER BY
            -- R.loadGroup, rptrName, clientShortName

            GO

      QUERY
      execute sql
    end
  end
end
