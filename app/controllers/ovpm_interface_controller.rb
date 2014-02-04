require 'csv'
require("chartdirector")

class OvpmInterfaceController < ApplicationController
  include ChartDirector::InteractiveChartSupport

  def index
    session[:current_service] = "system_performance"
    @page_title = "APJ"
    session[:prefix] = "Prefix from EnvVar"
    session[:user_id] = @user.id
    @service = Servicio.find(params[:service_id])
    @connection = @service.dbconection

    @performance_link = self.get_prefix("/sys_perf_graphs/getPerfGraph")
    @exception_page_link = self.get_prefix("/sys_cap_graphs/capacity_summary")
    @capacity_link = self.get_prefix("/sys_cap_graphs/getCapGraph")
    @capacity_storage_link = self.get_prefix("/storage_cap_graphs/getCapGraph")
    @capacity_storage_mtf_link = self.get_prefix("/storage_cap_graphs/capacity_storage_mtf")
    @system_information_link = self.get_prefix("/system_information/")
    @performance_storage_link = self.get_prefix('/storage_perf_graphs/getPerfGraph')

    @current_connection = session[:current_connection]

    if !@current_connection || @connection != @current_connection
      session[:current_connection] = @connection
    end  

    self.made_con(@connection)

    if @grouping_table
      @oslist = CustomGrouping.get_drop_list(@client.reporter_group,"osname")
      @filter1 = CustomGrouping.get_drop_list(@client.reporter_group,"filter1")
      @filter2 = CustomGrouping.get_drop_list(@client.reporter_group,"filter2")
      @filter3 = CustomGrouping.get_drop_list(@client.reporter_group,"filter3")
      @filter4 = CustomGrouping.get_drop_list(@client.reporter_group,"filter4")
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

    if @storage_summary_table and @servers.first
      #@fs_mountpoint = Storagemtfcapacity.getFileSystems(@servers.first.systemid) 
      @fs_mountpoint = Storagesummarycapacity.getFileSystems(@servers.first.systemid) 

      #render_text @fs_mountpoint
    end

    @metrics = @connection.Globalmetrics
    @zones = @client.Capacityzones
    #self.del_con()
  end

  def servers_list
    @client = session[:current_client]
    @searchText = params[:textserver]
    @connection = session[:current_connection]
    self.made_con(@connection)
    @groups_table = @connection.Dbtables.find_by_app_name("groups")
    @capacity_table = @connection.Dbtables.find_by_app_name("capacity_data")

    if @searchText.include? "'"  || (@searchText == '')
      @searchText = "";          
    end
    if @groups_table
      Group.table_name = @groups_table.db_table
      @servers = Group.servers_name(@client.reporter_group,@searchText)
    else 
      if @capacity_table
        Capacitydata.table_name = @capacity_table.db_table;
        @servers = Capacitydata.servers_name(@client.reporter_group,@searchText)
      end

    end

  end

  def servers_list_os
    @client = session[:current_client]
    @searchText =  @searchText = params[:textserver]
    @os = params[:osname]
    @connection = session[:current_connection]
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

  def capacity
    session[:current_service] = "systems_capacity"
    @capacity_link = self.get_prefix("/sys_cap_graphs/getCapGraph")
    @exception_page_link = self.get_prefix("/sys_cap_graphs/capacity_summary")
  end

  def performance
    session[:current_service] = "systems_performance"
    @performance_link = self.get_prefix("/sys_perf_graphs/getPerfGraph")
  end

  def capacity_storage
    session[:current_service] = 'storage_capacity'
    @capacity_storage_link = self.get_prefix('/storage_cap_graphs/capacity_storage_mtf')
  end

  def performance_storage
    session[:current_service] = "storage_capacity"
    @performance_storage_link = self.get_prefix('/storage_perf_graphs/getPerfGraph')
  end

  def system_info
    session[:current_service] = "system_info"
    @system_info_link = self.get_prefix('/system_information/')
    @connection = session[:current_connection]
    @capacity_table = @connection.Dbtables.find_by_app_name("capacity_data")
  end

  def index_grid
    @client = Client.find(params[:client_id])
    @list_servers = params[:GetServer]
    #@service = Service.find(params[:service_id])
    @connection = session[:current_connection]
    @monthyear = params[:monthyear]
    @dateFrom = params[:DateReportFrom]
    @dateTo = params[:DateReportTo]
    @storage_table = @connection.Dbtables.find_by_app_name("capacity_storage")
    if  @storage_table 
      StorageCapacity.remove_connection()  
      StorageCapacity.establish_connection(
        :adapter => @storage_table.type_db_server,
        :host => @storage_table.server_ip,
        :database => @storage_table.default_db,
        :username => @storage_table.user_name,
        :password => @storage_table.password,
        :autocommit => "false")
      StorageCapacity.connection.instance_variable_get("@connection")["AutoCommit"] = false
      StorageCapacity.table_name = @storage_table.db_table;
    end
    #@app_name = params[:appname]
    @app_name = 'all'
    #@host_name = params[:host_name]
    @host_name = 'all'
    #@fs_mount = params[:mount_point]
    @fs_mount = 'all'
    @in_servers = ""
    @num_servers = 0
    for server in @list_servers
      if @list_servers.length > 1 and @num_servers < (@list_servers.length - 1)
        @in_servers  = @in_servers + "'" + server + "'," 
      else
        @in_servers  = @in_servers + "'" + server + "'" 
      end      
      @num_servers = @num_servers + 1  
    end
    #    render_text @in_servers
    #    render_text @app_name + " " + @host_name + " " + " " + @client.reporter_group
    @strlist = StorageCapacity.getTradeStorageQuery(@in_servers,@client.description)
    @strlistneg = StorageCapacity.getTradeStorageQueryNeg(@in_servers,@client.description)
    @strlist = @strlist + @strlistneg
    #  @strlist.push(@strlistneg)
    #  render_text @strlist
  end

  def show_report_csv
    @client = Client.find(params[:client_id])
    @list_servers = params[:GetServer]
    #@service = Service.find(params[:service_id])
    @connection = session[:current_connection]
    @monthyear = params[:monthyear]
    @dateFrom = params[:DateReportFrom]
    @dateTo = params[:DateReportTo]
    @storage_table = @connection.Dbtables.find_by_app_name("capacity_storage")
    if  @storage_table 
      StorageCapacity.remove_connection()  
      StorageCapacity.establish_connection(
        :adapter => @storage_table.type_db_server,
        :host => @storage_table.server_ip,
        :database => @storage_table.default_db,
        :username => @storage_table.user_name,
        :password => @storage_table.password,
        :autocommit => "false")
      StorageCapacity.connection.instance_variable_get("@connection")["AutoCommit"] = false
      StorageCapacity.table_name = @storage_table.db_table;
    end
    #@app_name = params[:appname]
    @app_name = 'all'
    #@host_name = params[:host_name]
    @host_name = 'all'
    #@fs_mount = params[:mount_point]
    @fs_mount = 'all'
    @in_servers = ""
    @num_servers = 0
    for server in @list_servers
      if @list_servers.length > 1 and @num_servers < (@list_servers.length - 1)
        @in_servers  = @in_servers + "'" + server + "'," 
      else
        @in_servers  = @in_servers + "'" + server + "'" 
      end      
      @num_servers = @num_servers + 1  
    end
    @strlist = StorageCapacity.getTradeStorageQuery(@in_servers,@client.description)
    @strlistneg = StorageCapacity.getTradeStorageQueryNeg(@in_servers,@client.description)
    @strlist = @strlist + @strlistneg
    now = Time.now
    namefile = now.day.to_s << "_" << now.month.to_s << "_" << now.year.to_s << "_storage.csv"   
    report = StringIO.new
    CSV::Writer.generate(report, ',') do |csv|
      csv << %w(Group_Name Host_Name File_System Start_Used Start_Date Fs_Total Fs_Used Fs_Free Fs_Used_PCT Fill_Days )
      for line in @strlist
        csv << [line.netid, line.host_name, line.fs_mountpointname.sub(/[\\]/, '*'), line.start_used, line.start_date.strftime("%b/%d/%Y"), line.FS_TOTAL,line.FS_USED, line.FS_FREE, line.fs_usedpct, line.filldays]
      end
    end

    report.rewind
    send_data(report.read,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :filename => namefile)

  end

  def change
    @rails_version = Rails::VERSION::STRING
  end

  def made_con (conn)
    @grouping_table = conn.Dbtables.find_by_app_name("custom_grouping")
    @capacity_table = conn.Dbtables.find_by_app_name("capacity_data")
    @global_table = conn.Dbtables.find_by_app_name("global")
    @storage_MTF_table = @connection.Dbtables.find_by_app_name("Extract_Storage_MTF")
    @storage_summary_table = @connection.Dbtables.find_by_app_name("Extract_Storage_summary")
    @storage_forecast_table = @connection.Dbtables.find_by_app_name("Extract_Storage_forecast")
    @storage_performance_table = @connection.Dbtables.find_by_app_name("RDS_LVOLUME_FILESYSTEMS")

    if @grouping_table
      CustomGrouping.remove_connection()  
      CustomGrouping.establish_connection(
        :adapter => @grouping_table.type_db_server,
        :host => @grouping_table.server_ip,
        :database => @grouping_table.default_db,
        :username => @grouping_table.user_name,
        :password => @grouping_table.password,
        :autocommit => "false")
      CustomGrouping.connection.instance_variable_get("@connection")["AutoCommit"] = false
      CustomGrouping.table_name = @grouping_table.db_table;

    else
      @groups_table = conn.Dbtables.find_by_app_name("groups")
      if  @groups_table 
        Group.remove_connection()  
        Group.establish_connection(
          :adapter => @groups_table.type_db_server,
          :host => @groups_table.server_ip,
          :database => @groups_table.default_db,
          :username => @groups_table.user_name,
          :password => @groups_table.password,
          :autocommit => "false")
        Group.connection.instance_variable_get("@connection")["AutoCommit"] = false
        Group.table_name = @groups_table.db_table;
      end
      @server_aliases = conn.Dbtables.find_by_app_name("ServerAlias")
    end    
    @systems_table = conn.Dbtables.find_by_app_name("systems")
    if @systems_table
      System.remove_connection()     
      System.establish_connection(
        :adapter => @systems_table.type_db_server,
        :host => @systems_table.server_ip,
        :database => @systems_table.default_db,
        :username => @systems_table.user_name,
        :password => @systems_table.password,
        :autocommit => "false")
      System.table_name = @systems_table.db_table;   
      System.connection.instance_variable_get("@connection")["AutoCommit"] = false
    end

    if @capacity_table
      Capacitydata.remove_connection()     
      Capacitydata.establish_connection(
        :adapter => @capacity_table.type_db_server,
        :host => @capacity_table.server_ip,
        :database => @capacity_table.default_db,
        :username => @capacity_table.user_name,
        :password => @capacity_table.password,
        :autocommit => "false")
      Capacitydata.table_name = @capacity_table.db_table;   
      Capacitydata.connection.instance_variable_get("@connection")["AutoCommit"] = false
    end

    if  @storage_MTF_table 
      Storagemtfcapacity.remove_connection()  
      Storagemtfcapacity.establish_connection(
        :adapter => @storage_MTF_table.type_db_server,
        :host => @storage_MTF_table.server_ip,
        :database => @storage_MTF_table.default_db,
        :username => @storage_MTF_table.user_name,
        :password => @storage_MTF_table.password,
        :autocommit => "false")
      Storagemtfcapacity.connection.instance_variable_get("@connection")["AutoCommit"] = false
      Storagemtfcapacity.table_name = @storage_MTF_table.db_table;
    end  

    if  @storage_summary_table 
      Storagesummarycapacity.remove_connection()  
      Storagesummarycapacity.establish_connection(
        :adapter => @storage_summary_table.type_db_server,
        :host => @storage_summary_table.server_ip,
        :database => @storage_summary_table.default_db,
        :username => @storage_summary_table.user_name,
        :password => @storage_summary_table.password,
        :autocommit => "false")
      Storagesummarycapacity.connection.instance_variable_get("@connection")["AutoCommit"] = false
      Storagesummarycapacity.table_name = @storage_summary_table.db_table;
    end    

    if  @storage_forecast_table 
      Storageforecastcapacity.remove_connection()  
      Storageforecastcapacity.establish_connection(
        :adapter => @storage_forecast_table.type_db_server,
        :host => @storage_forecast_table.server_ip,
        :database => @storage_forecast_table.default_db,
        :username => @storage_forecast_table.user_name,
        :password => @storage_forecast_table.password,
        :autocommit => "false")
      Storageforecastcapacity.connection.instance_variable_get("@connection")["AutoCommit"] = false
      Storageforecastcapacity.table_name = @storage_forecast_table.db_table;
    end  
  end

  def del_con
    Group.remove_connection()  
    System.remove_connection()     
    Capacitydata.remove_connection()     
  end

  def get_prefix(initpath)
    if session[:prefix]
      return session[:prefix] + initpath
    else
      return initpath
    end
  end

end
