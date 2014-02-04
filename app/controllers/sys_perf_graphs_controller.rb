require 'chartdirector'
class SysPerfGraphsController < ApplicationController
  include ChartDirector::InteractiveChartSupport
  protect_from_forgery :only => [:create, :update, :destroy] 
  def getPerfGraph()
    @connection = session[:current_connection]
    @datereport = params[:datereport]
    @typereport = params[:typereport]
    @getserver  = params[:GetServer]
    session[:server_alias] = params[:server_alias]
    if @datereport != ""
      @typereport = "Daily"
    end
    @allmetrics = @connection.Globalmetrics.find(:all)
    @metrics_availables = Array.new
    for metric in @allmetrics
      params.each do |key, value|
        if metric.name == key
          if !@ccunit || @ccunit == metric.globalunit_id
            @metrics_availables << metric
            @ccunit = metric.globalunit_id
            @lastmetric = metric
          else
            @nosameunit = true
          end
        end
      end
    end

    @title = "Performance Graphs"
    @ctrl_file = File.expand_path(__FILE__)
    @noOfCharts = 1
  end

  def getPerfchart
    @connection = session[:current_connection]
    @client = Client.find(params[:client_id])
    @metrics_avalables = session[:metrics_availables]
    @datereport = params[:datereport]
    @getserver = params[:getserver]
    @typereport = params[:typereport]
    @now = Time.now
    @cserver = @getserver.gsub(/[.]/, '_')
    session[:step] = '0'
    @server_alias = session[:server_alias]

    @global_table = @connection.Dbtables.find_by_app_name("Global")
    if @global_table
      Global.remove_connection()
      Global.establish_connection(
        :adapter => @global_table.type_db_server,
        :host => @global_table.server_ip,
        :database => @global_table.default_db,
        :username => @global_table.user_name,
        :password => @global_table.password,
        :autocommit => "false")
      Global.table_name = @global_table.db_table;
    end

    sqlMetricString = ""
    session[:metricsin] =  @metrics_avalables
    for metric in @metrics_avalables
      strmetbuild = metric.sumfuction + "(" + metric.dbname + ") as "
      sqlMetricString = Global.buildMetricsString(strmetbuild,"'" + metric.name + "'",sqlMetricString)
      instance_variable_set("@#{metric.name}",Array.new)
    end 
    if @server_alias 
      @server_name = Serveralias.get_alias(@getserver)
      if @server_name.first
        @server_name = @getserver  +  "-" + @server_name.first.Alias
      else
        @server_name = @getserver
      end
    else
      @server_name = @getserver
    end

    if sqlMetricString != ""
      case @typereport
      when "Daily"
        datalist = Global.getDayMetricsGlobalUtilMSQL(sqlMetricString,@getserver,@datereport)
        date_title =  Time.parse(@datereport).strftime("%B, %d, %Y")

        xtitle = "Hours / Day"

      when "LastWeek"
        hours = [0,6,12,18]
        datalist = Global.getLastWeekMetricsGlobalUtilMSQL(sqlMetricString,@getserver,'7')
        date_title =  7.days.ago.strftime("%b %d, %Y")  + " - " + 1.day.ago.strftime("%b %d, %Y")
        xtitle = "Hours / Day"
      when "CurrentMonth"
        hours = [12]
        days_ago = Time.now.strftime("%d").to_i
        days_ago = days_ago - 1
        datalist = Global.getLastWeekMetricsGlobalUtilMSQL(sqlMetricString,@getserver,days_ago.to_s)
        date_title =   days_ago.days.ago.strftime("%b %d, %Y")  + " - " + 1.day.ago.strftime("%b %d, %Y")
        xtitle = "Hours / Day"
      when "LastMonth"
        hours = [12]
        datalist = Global.getLastMonthMetricsGlobalUtilMSQL(sqlMetricString,@getserver,"1")
        date_title =   1.month.ago.strftime("%B %Y")
        xtitle = "Hours / Day"
      end

      labels = []
      datalist.each do |r|
        if @typereport == "Daily"
          if r.hour < 10
            labels.push("0" + r.hour.to_s + ":00")
          else
            labels.push(r.hour.to_s + ":00")
          end
        else
          if (hours.include?(r.hour))
            if r.hour < 10
              hourtoin = "0" + r.hour.to_s + ":00"
            else
              hourtoin = r.hour.to_s + ":00"
            end
            labels.push(r.month.to_s + "/" + r.day.to_s + "/" + r.year.to_s + " " + hourtoin)
          else
            labels.push("")
          end
        end
        @metrics_avalables.each do |m|
          instance_eval("@#{m.name}").push(r[m.name].to_f)
        end
      end
    end
    c = ChartDirector::XYChart.new(600, 370, 0xffffff, 0xFF000000 , 0) 

    if globalunit
      c.addTitle(
        @typereport + " Graph " + globalunit.showname + 
        "\n <*font=arialbd.ttf,size=10*>" +
        date_title +
        "\n Server :: " + @server_name + " ", "arialbd.ttf", 12)
    end
    if @typereport == "Daily" 
      c.setPlotArea(60, 62, 500, 200, 0xffffff, 0xf8f8f8, ChartDirector::Transparent, c.dashLineColor(0xcccccc, ChartDirector::DotLine), c.dashLineColor(0xcccccc, ChartDirector::DotLine))
    else
      c.setPlotArea(60, 62, 500, 200, 0xffffff, 0xf8f8f8, ChartDirector::Transparent)
    end

    c.addLegend(60, 320, false, "arialbd.ttf", 8).setBackground(ChartDirector::Transparent)
    c.addText(0, 356, "1994-#{Time.now.year} Hewlett-Packard Company All Rights Reserved - Global Delivery Capacity & Performance Management.", "arial.ttf", 7)

    c.yAxis().setTickDensity(30)

    # Set axis label style to 8pts Arial Bold
    c.xAxis().setLabelStyle("arial.ttf", 7)
    c.yAxis().setLabelStyle("arial.ttf", 7)

    # Set axis line width to 2 pixels
    c.xAxis().setWidth(1)
    c.yAxis().setWidth(1)
    c.xAxis().setLabels(labels).setFontAngle(45)

    # Add axis title using 10pts Arial Bold Italic font
    if globalunit
      c.yAxis().setTitle(globalunit.showname, "arialbd.ttf", 9)
    end  
    c.xAxis().setTitle(xtitle, "arialbd.ttf", 9)
    c.xAxis().setTitlePos(3)     
    #c.yAxis().setLinearScale(0, 100, 20) 

    # Add a line layer to the chart
    layer = c.addLineLayer2()

    # Set the line width to 3 pixels
    layer.setLineWidth(1)

    # Add the three data sets to the line layer, using circles, diamands and X shapes
    # as symbols
    #layer.addDataSet(data0, 0xff0000, "Quantum Computer").setDataSymbol(ChartDirector::CircleSymbol, 9)
    #

    incol=0
    @metrics_avalables.each do |m|
      datain = Array.new(instance_eval("@#{m.name}"))
      #          layer.addDataSet(datain,eval(m.color).to_i, m.name)
      layer.addDataSet(datain,eval(m.description).to_i, m.name)
      incol += 1
    end  
    if globalunit
      if datalist.length <= 0
        c.addText(150, 140, "There is no data to build this graph.", "arial.ttf", 15)
      end
    else
      @nometric = true
      c.addText(94, 140, "There is no metric selected to build the graph.", "arial.ttf", 15)
    end

    dir = EnvVar.getVal('graphs_folder').value 
    vdir = "/files/graphs/"
    @namefile = c.makeTmpFile(dir)
    @imgpath = vdir + @namefile
  end

  def perfdata
    @connection = session[:current_connection]
    @client = session[:client_id]
    @metrics_avalables = session[:metrics_availables]
    @datereport = session[:datereport]
    @getserver = params[:getserver]
    @getserver = @getserver.gsub(/[_]/, '.')  
    @typereport = session[:typereport]
    @now = Time.now

    @global_table = @connection.Dbtables.find_by_app_name("global")
    if @global_table
      Global.remove_connection()  
      Global.establish_connection(
        :adapter => @global_table.type_db_server,
        :host => @global_table.server_ip,
        :database => @global_table.default_db,
        :username => @global_table.user_name,
        :password => @global_table.password,
        :autocommit => "false")
      Global.table_name = @global_table.db_table;
    end 

    sqlMetricString = ""  
    for metric in @metrics_avalables
      strmetbuild = metric.sumfuction + "(" + metric.dbname + ") as "
      sqlMetricString = Global.buildMetricsString(strmetbuild,"'" + metric.name + "'",sqlMetricString)
    end 

    case @typereport
    when "Daily"
      @datalist = Global.getDayMetricsGlobalUtilMSQL(sqlMetricString,@getserver,@datereport)
      @xtitle = "Hours / Day"
    when "LastWeek"
      @datalist = Global.getLastWeekMetricsGlobalUtilMSQL(sqlMetricString,@getserver,'7')
      @xtitle = "Hours / Day"
    when "CurrentMonth"
      days_ago = Time.now.strftime("%d").to_i
      days_ago = days_ago - 1
      @datalist = Global.getLastWeekMetricsGlobalUtilMSQL(sqlMetricString,@getserver,days_ago.to_s)
      @xtitle = "Hours / Day"
    when "LastMonth"
      @datalist = Global.getLastMonthMetricsGlobalUtilMSQL(sqlMetricString,@getserver,"1")
      @xtitle = "Hours / Day"
    end

  end

  def clear_div
    render :text => ""
  end

  def perfnote
    @connection = session[:current_connection]
    @client = session[:client_id]
    @metrics_avalables = session[:metrics_availables]
    @datereport = session[:datereport]
    @getserver = params[:getserver]
    @cserver = @getserver
    @getserver = @getserver.gsub(/[_]/, '.') 
    @typereport = session[:typereport]
    @user = User.find(session[:user_id])
    @att = Rattribute.find(:all, :conditions=>['name = ? or name = ?','notes','notes_admin'],:order =>'name desc')
    @att_notes = @user.role.Rattributes.include? @att[1]
    @notes_admin = @user.role.Rattributes.include? @att[0]

    @notes = NotesServers.getnotes(@typereport || '',@datereport || '',@getserver || '',@client.reporter_group || '','performance')
  end

  def add_note
    @connection = session[:current_connection]
    @client = session[:client_id]
    @datereport = session[:datereport]
    @getserver = params[:getserver]
    @cserver = @getserver 
    @getserver = @getserver.gsub(/[_]/, '.') 
    @note = NotesServers.new()
    @note.date_ref = 1.day.ago
  end

  def edit_note
    @connection = session[:current_connection]
    @client = session[:client_id]
    @datereport = session[:datereport]
    @note = NotesServers.find(params[:note_id])
    @note.date_note = Time.now()
    @getserver = @note.systemid 
    @cserver = @getserver
  end

  def save_note
    @connection = session[:current_connection]
    @client = session[:client_id]
    @datereport = session[:datereport]
    @typereport = session[:typereport]

    @note = NotesServers.new(params[:note])    
    @note.date_note = Time.now()
    @note.user_id = session[:user_id]
    @client = Client.find(session[:client_id])
    @note.client_group = @client.reporter_group
    @user = User.find(session[:user_id])
    @att = Rattribute.find(:all, :conditions=>['name = ? or name = ?','notes','notes_admin'],:order =>'name desc')
    @att_notes = @user.role.Rattributes.include? @att[1]
    @notes_admin = @user.role.Rattributes.include? @att[0]
    @getserver = @note.systemid 
    @cserver = @getserver
    if @note.save
      @notes = NotesServers.getnotes(@typereport || '',@datereport || '',@getserver || '',@client.reporter_group || '','performance')
      render :action => "perfnote"
    else
      render :action => "add_note"
    end
  end

  def update_note
    @connection = session[:current_connection]
    @client = session[:client_id]
    @datereport = session[:datereport]
    @typereport = session[:typereport]
    @note = NotesServers.find(params[:id])
    @user = User.find(session[:user_id])
    @att = Rattribute.find(:all, :conditions=>['name = ? or name = ?','notes','notes_admin'],:order =>'name desc')
    @att_notes = @user.role.Rattributes.include? @att[1]
    @notes_admin = @user.role.Rattributes.include? @att[0]
    @getserver = @note.systemid 
    @cserver = @getserver
    if @note.update_attributes!(params[:note])
      @notes = NotesServers.getnotes(@typereport || '',@datereport || '',@getserver || '',@client.reporter_group || '','performance')
      render :action => "perfnote"
    end
  end

  def delete_note
    @connection = session[:current_connection]
    @client = session[:client_id]
    @datereport = session[:datereport]
    @typereport = session[:typereport]
    @cserver = @getserver
    @note = NotesServers.find(params[:note_id])
    @getserver = @note.systemid 
    @user = User.find(session[:user_id])
    @att = Rattribute.find(:all, :conditions=>['name = ? or name = ?','notes','notes_admin'],:order =>'name desc')
    @att_notes = @user.role.Rattributes.include? @att[1]
    @notes_admin = @user.role.Rattributes.include? @att[0]
    if @note.destroy
      @notes = NotesServers.getnotes(@typereport || '',@datereport || '',@getserver || '',@client.reporter_group || '','performance')
      render :action => "perfnote"
    end
  end

end
