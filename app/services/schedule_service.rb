require 'cassandra'

class ScheduleService

  @canOrderBy = %w[arrivingAt time train goingTo]

  def initialize
    begin
      @cluster = Cassandra.cluster(hosts: %w[137.112.104.137 137.112.104.136 137.112.104.138], connect_timeout: 1)
      @stations = @cluster.connect("stations")
      http_adaptor = Neo4j::Core::CypherSession::Adaptors::HTTP.new('http://neo4j:Onrails433@137.112.104.139:7474')
      neo4j_session = Neo4j::Core::CypherSession.new(http_adaptor)
    rescue Cassandra::Errors::NoHostsAvailable, Neo4j::Core::CypherError::NoHostsAvailable

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
    cassandraQuery = 'INSERT INTO arrivals (arrivingat, time, goingto, price) VALUES (?,?,?,?) IF NOT EXISTS'
    cassandraArguments = [arrivingAt, time, goingTo, price]
    cassandraDatabase = 'Cassandra'
    Log.addToLog(cassandraDatabase, cassandraQuery, cassandraArguments)

    neoQuery = 'Merge(arrivingAt:Station {city:?}) Merge(goingTo:Station {city:?}) MERGE (arrivingAt)-[:track {operational:true}]->(goingTo)'
    neoArguments = [arrivingAt, goingTo]
    neoDatabase = 'Neo4j'
    Log.addToLog(neoDatabase, neoQuery, neoArguments)
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

  def deleteStation(station)
    cassandraQuery = 'Delete From arrivals Where arrivingat = ? or goingTo = ? IF EXISTS'
    cassandraArguments = [station, station]
    cassandraDatabase = 'Cassandra'
    Log.addToLog(cassandraQuery, cassandraArguments, cassandraDatabase)

    neoQuery = 'MATCH (n:Station { name: ? }) Detach DELETE n'
    neoArguments = [station]
    neoDatabase = 'Neo4j'
    Log.addToLog(neoDatabase, neoQuery, neoArguments)
  end

  def getStations
    neoQuery = 'Match(n:Station) return n.city'
    neoArguments = []
    neoDatabase = 'Neo4j'
    Log.addToLog(neoDatabase, neoQuery, neoArguments)
  end

  def getSchedule
    if @stations.nil?
      return nil
    else
      search = @stations.prepare("Select * From arrivals")
      results = @stations.execute(search)
      return results
    end
  end

  def setTrackOperational(arrivingAt, goingTo, isOperational)
    if isOperational
      neoQuery = 'Match (arrivingAt:Station {city:?})-[t:track]->(goingTo:Station {city:?}) Set t.operational = true'
    else
      neoQuery = 'Match (arrivingAt:Station {city:?})-[t:track]->(goingTo:Station {city:?}) Set t.operational = false'
    end
    neoArguments = [arrivingAt, goingTo]
    neoDatabase = 'Neo4j'
    Log.addToLog(neoDatabase, neoQuery, neoArguments)
  end

  def getAllRoutes
    neoQuery = 'Match(n:Station)-[t:track]->(m:Station) Where n.city <> m.city Return Distinct n.city,m.city,t.operational'
    neoArguments = []
    neoDatabase = 'Neo4j'
    Log.addToLog(neoDatabase, neoQuery, neoArguments)
  end

  def filterRoutes(arrivingAt, goingTo)
    if arrivingAt == "" and goingTo == ""
      return getAllRoutes
    elsif arrivingAt == ""
      neoQuery = 'Match(n:Station)-[t:track]->(m:Station) Where n.city <> m.city and n.city = ? Return Distinct n.city,m.city,t.operational'
      neoArguments = [arrivingAt]
    elsif goingTo == ""
      neoQuery = 'Match(n:Station)-[t:track]->(m:Station) Where n.city <> m.city and m.city = ? Return Distinct n.city,m.city,t.operational'
      neoArguments = [goingTo]
    else
      neoQuery = 'Match(n:Station)-[t:track]->(m:Station) Where n.city <> m.city and n.city = ? and m.city = ? Return Distinct n.city,m.city,t.operational'
      neoArguments = [arrivingAt, goingTo]
    end

    neoDatabase = 'Neo4j'
    Log.addToLog(neoDatabase, neoQuery, neoArguments)
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
