require 'csv'
require("chartdirector")
=begin
{
grouping_table => "custom_grouping",
capacity_table => "capacity_data",
global_table => "global",
storage_MTF_table => "Extract_Storage_MTF",
storage_summary_table => "Extract_Storage_summary",
storage_forecast_table => "Extract_Storage_forecast",
storage_performance_table => "RDS_LVOLUME_FILESYSTEMS"
}
=end
class OvpmInterfaceController < ApplicationController
  include ChartDirector::InteractiveChartSupport
  def index
    @service = Service.find(params[:service_id])
    @connection = @service.dbconnection
    @oslist = get_os_list_for_client
    @servers = get_servers_for_client
    if @storage_summary_table and @servers.first
      @fs_mountpoint = Storagesummarycapacity.getFileSystems(@servers.first.systemid) 
    end
    @metrics = @connection.Globalmetrics
    @zones = @client.Capacityzones
  end

  def servers_list_os
    # sets the server instance variable and updates the 'GetServer' selectbox 
    @servers = get_servers_for_client
    #update_the_select_box on client_side

    self.made_con(@connection)
    @grouping_table = @connection.Dbtables.find_by_app_name("custom_grouping")
    if @grouping_table
      @f1 = params[:filter1]
      @f2 = params[:filter2]
      @f3 = params[:filter3]
      @f4 = params[:filter4]
      CustomGrouping.table_name = @grouping_table.db_table
      @servers = CustomGrouping.get_servers_filter(@client.reporter_group,@os,@f1,@f2,@f3,@f4,@searchText)
      #render_text @servers
    else
      @groups_table = @connection.Dbtables.find_by_app_name("groups")
      if @groups_table
        Group.table_name = @groups_table.db_table
        @server_aliases = @connection.Dbtables.find_by_app_name("ServerAlias")

        if @server_aliases and @searchText != ""
          @servers = Group.servers_os(@client.reporter_group,@os,"")
        else
          @servers = Group.servers_os(@client.reporter_group,@os,@searchText)
        end    

        if @server_aliases
          @servers.each {|serv|
            ali = Serveralias.get_alias(serv.systemid)
            if ali.length > 0
              serv.alias = serv.systemid + '-' +ali[0].Alias
            else
              serv.alias = serv.systemid
            end
          }
          if @searchText != ""
            @serversfil = @servers.find_all{|ser| ser.alias.scan(@searchText).size > 0}
            @servers = @serversfil
          end
        end
      else
        @capacity_table = @connection.Dbtables.find_by_app_name("capacity_data")
        if @capacity_table
          Capacitydata.table_name = @capacity_table.db_table
          @servers = Capacitydata.servers_os(@client.reporter_group,@os,@searchText)
        end  
      end  
    end

    logger.info("PARAMS: #{@servers.first.inspect}")
    render :update do |page| 
      if @server_aliases     
        page << update_select_box("GetServer",
                                  @servers,
                                  {:text => :alias,:value=>:systemid,:title=>:systemid,:include_blank=>false}
                                 )  
      else
        page << update_select_box("GetServer",
                                  @servers,
                                  {:text => :systemid,:value=>:systemid,:title=>:systemid,:include_blank=>false}
                                 )  
      end                              

      page.replace_html  'NumServers', @servers.length.to_s + ' Servers'   

      @storage_summary_table = @connection.Dbtables.find_by_app_name("Extract_Storage_summary")  
      if  @storage_summary_table 
        logger.info("PARAMS: #{@servers[1].inspect}")

        Storagesummarycapacity.table_name = @storage_summary_table.db_table;

        @fs_mountpoint = Storagesummarycapacity.getFileSystems(@servers.first.systemid)  
        #@fs_mountpoint = Storagesummarycapacity.getFileSystems(@servers.first.systemid,@client.reporter_group)  

        current_service = session[:current_service]
        #  if current_service == "storage_capacity" 

        page.show  'storage_select_box' 
        page << update_select_box("fs_mountpoint",
                                  @fs_mountpoint,
                                  {:text => :filesystem,:value=>:filesystem,:title=>:filesystem,:include_blank=>false}
                                 )  
        # page.replace_html  'NumServers', @server 
        page.replace_html 'NumFileSystems', @fs_mountpoint.size.to_s + "_Files_Systems"
        if current_service != "storage_capacity"
          page.hide  'storage_select_box' 
        end
      end  

      page.GetGraph.submit()                                
    end
  end

  private 
=begin
    if @grouping_table
      @oslist = CustomGrouping.get_drop_list(@client.reporter_group,"osname")
      @servers = CustomGrouping.servers(@client.reporter_group)
    else
      if @systems_table
        @oslist = System.oslist(@client.reporter_group)
      else
        if @capacity_table
          Capacitydata.table_name = @capacity_table.db_table; 
          @oslist = Capacitydata.oslist(@client.reporter_group)
        end
      end

      #return render :text => "the os list es :#{@oslist.size}"

      if @groups_table
        @servers = Group.servers_name(@client.reporter_group,'')
        if @server_aliases
          @servers.each {|serv|
            ali = Serveralias.get_alias(serv.systemid)
            if ali.length > 0
              serv.alias = serv.systemid + '-' +ali[0].Alias
            else
              serv.alias = serv.systemid
            end
          }
        end
      else
        if @capacity_table
          Capacitydata.table_name = @capacity_table.db_table; 
          @servers = Capacitydata.servers(@client.reporter_group)
        end
      end

    end
=end

end
