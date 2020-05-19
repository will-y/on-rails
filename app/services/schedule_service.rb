require 'cassandra'

class ScheduleService

  @canOrderBy = %w[arrivingAt time train goingTo]

  def initialize
    begin
      @cluster = Cassandra.cluster(hosts: %w[137.112.104.137 137.112.104.136 137.112.104.138], connect_timeout: 1)
      @stations = @cluster.connect("stations")
    rescue Cassandra::Errors::NoHostsAvailable
    end
  end

  def addToSchedule(arrivingAt, time, goingTo, price)
    #seeIfExists = @stations.prepare('SELECT * From arrivals Where arrivingat = ? and time = ? and goingto = ? ALLOW FILTERING;')
    #addTrainTime = @stations.prepare('INSERT INTO arrivals (arrivingat, time, goingto, price) VALUES (?,?,?,?) IF NOT EXISTS')
    #duplicates = @stations.execute(seeIfExists, arguments: [arrivingAt, time, goingTo])
    # if not duplicates.empty?
    #  return "This station, time, and destination combination already exists";
    #else
    #  @stations.execute(addTrainTime, arguments: [arrivingAt, time, goingTo, price])
    # return ""
    # end
    query = 'INSERT INTO arrivals (arrivingat, time, goingto, price) VALUES (?,?,?,?) IF NOT EXISTS'
    arguments = [arrivingAt, time, goingTo, price]
    database = 'Cassandra'
    Log.addToLog(database, query, arguments)
  end

  def editSchedule (oldArrivingAt, oldTime, oldGoingTo, newArrivingAt, newTime, newGoingTo, newPrice)
    #seeIfExists = @stations.prepare('SELECT * From arrivals Where arrivingat = ? and time = ? and goingto = ? LIMIT 1 ALLOW FILTERING;')

    #exists = @stations.execute(seeIfExists, arguments: [oldArrivingAt, oldTime, oldGoingTo])
    #if not exists.empty?
    removeFromSchedule(oldArrivingAt, oldTime, oldGoingTo)
    addToSchedule(newArrivingAt, newTime, newGoingTo, newPrice)
    #  return ""
    #else
    #  return "This station, time, and destination combination does not exist";
    #end

  end

  def removeFromSchedule(arrivingAt, time, goingTo)
    #seeIfExists = @stations.prepare('SELECT * From arrivals Where arrivingat = ? and time = ? and goingto = ? LIMIT 1 ALLOW FILTERING;')
    #removeTrainTime = @stations.prepare('Delete From arrivals Where arrivingat = ? and time = ? and goingto = ? IF EXISTS')

    #exists = @stations.execute(seeIfExists, arguments: [arrivingAt, time, goingTo])
    #if not exists.empty?
    #  @stations.execute(removeTrainTime, arguments: [arrivingAt, time, goingTo])
    #  return ""
    #else
    #  return "This station, time, and destination combination does not exist";
    #end
    query = 'Delete From arrivals Where arrivingat = ? and time = ? and goingto = ? IF EXISTS'
    arguments = [arrivingAt, time, goingTo]
    database = 'Cassandra'
    # log = Log.new()
    Log.addToLog(database, query, arguments)
  end

  def getSchedule
    if @stations.nil?
      return nil
    else
      search = @stations.prepare("Select * From arrivals")
      results = @stations.execute(search)
      return results
    end

    # query = 'Select * From arrivals'
    #arguments = Array.new()
    #database = 'Cassandra'
    #log = Log.new()
    #Log.addToLog(database, query, arguments)
  end

  def get_row(arrivingAt, time, goingTo)
    if @stations.nil?
      return nil
    else
      search = @stations.prepare("Select * From arrivals Where arrivingat = ? and time = ? and goingto = ? ALLOW FILTERING;")
      results = @stations.execute(search, arguments: [arrivingAt, time, goingTo])
      return results;
      # query = "Select * From arrivals Where arrivingat = ? and time = ? and goingto = ? ALLOW FILTERING;"
      #arguments = [arrivingAt, time, goingTo]
      #database = 'Cassandra'
      #log = Log.new()
      #Log.addToLog(database, query, arguments)
      # end
    end
  end


  def filter (arrivingAt, time, goingTo)
    if @stations.nil?
      return nil
    else
      query = "Select * From arrivals"
      isFirstElement = true;

      if arrivingAt != ''
        if isFirstElement
          query = query + " Where arrivingat = '" + arrivingAt + "'"
          isFirstElement = false;
        else
          query = query + " and arrivingat = '" + arrivingAt + "'"
        end
      end

      if time != ''
        if isFirstElement
          query = query + " Where time = '" + time + "'"
          isFirstElement = false;
        else
          query = query + " and time = '" + time + "'"
        end
      end

      if goingTo != ''
        if isFirstElement
          query = query + " Where goingto = '" + goingTo + "'"
          isFirstElement = false;
        else
          query = query + " and goingto = '" + goingTo + "'"
        end
      end

      search = @stations.prepare(query + " allow filtering;")
      results = @stations.execute(search)
      return results

      #return results
      #query = query + " allow filtering;"
      #arguments = Array.new()
      #database = 'Cassandra'
      #log = Log.new()
      #Log.addToLog(database, query, arguments)

    end
  end
end
