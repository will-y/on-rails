require 'cassandra'
require 'neo4j/core/cypher_session/adaptors/http'

class ScheduleService

  @canOrderBy = %w[arrivingAt time train goingTo]

  def initialize
    begin
      @cluster = Cassandra.cluster(hosts: %w[137.112.104.137 137.112.104.136 137.112.104.138], connect_timeout: 1)
      @stations = @cluster.connect("stations")
      http_adaptor = Neo4j::Core::CypherSession::Adaptors::HTTP.new('http://neo4j:Onrails433@137.112.104.139:7474')
      @neo4j_session = Neo4j::Core::CypherSession.new(http_adaptor)
      @isConnected = http_adaptor.connected?
    rescue Cassandra::Errors::NoHostsAvailable, Neo4j::Core::CypherSession::ConnectionFailedError
    end
  end

  def addToSchedule(arrivingAt, time, goingTo, price)
    cassandraQuery = 'INSERT INTO arrivals (arrivingat, time, goingto, price) VALUES (?,?,?,?) IF NOT EXISTS'
    cassandraArguments = [arrivingAt, time, goingTo, "DECIMAL_#{price}"]
    cassandraDatabase = 'Cassandra'
    Log.addToLog(cassandraDatabase, cassandraQuery, cassandraArguments)

    neoQuery = "Merge(arrivingAt:Station {city:'#{arrivingAt}'}) Merge(goingTo:Station {city:'#{goingTo}'}) MERGE (arrivingAt)-[:track {operational:'true'}]->(goingTo)"
    neoArguments = [arrivingAt, goingTo]
    neoDatabase = 'Neo4j'
    Log.addToLog(neoDatabase, neoQuery, neoArguments)
  end

  def editSchedule (oldArrivingAt, oldTime, oldGoingTo, newArrivingAt, newTime, newGoingTo, newPrice)
    removeFromSchedule(oldArrivingAt, oldTime, oldGoingTo)
    addToSchedule(newArrivingAt, newTime, newGoingTo, newPrice)
  end

  def removeFromSchedule(arrivingAt, time, goingTo)
    query = 'Delete From arrivals Where arrivingat = ? and time = ? and goingto = ? IF EXISTS'
    arguments = [arrivingAt, time, goingTo]
    database = 'Cassandra'
    Log.addToLog(database, query, arguments)
  end

  def addStation(station)
    neoQuery = "Merge(n:Station {city:'#{station}'})"
    neoArguments = [station]
    neoDatabase = 'Neo4j'
    Log.addToLog(neoDatabase, neoQuery, neoArguments)
  end

  def deleteStation(station)
    cassandraQuery = 'Delete From arrivals Where arrivingat = ? IF EXISTS'
    cassandraArguments = [station]
    cassandraDatabase = 'Cassandra'
    Log.addToLog(cassandraDatabase, cassandraQuery, cassandraArguments)
    cassandraQuery = 'Delete From arrivals Where goingto = ? IF EXISTS'
    Log.addToLog(cassandraDatabase, cassandraQuery, cassandraArguments)

    neoQuery = "MATCH (n:Station { city: '#{station}' }) DETACH DELETE n"
    neoArguments = [station]
    neoDatabase = 'Neo4j'
    Log.addToLog(neoDatabase, neoQuery, neoArguments)
  end


  def getStations
    begin
      neoQuery = 'Match(n:Station) return n.city ORDER BY n.city'
      #neoArguments = []
      #neoDatabase = 'Neo4j'
      results = @neo4j_session.query(neoQuery)
      return results
    rescue Neo4j::Core::CypherSession::ConnectionFailedError
      return nil
    end
  end

  def formatResult(results)
    if !results.first().nil?
      formattedResults = Array.new()
      currentArrivingAt = results.first()["arrivingat"]
      currentGoingTo = results.first()["goingto"]
      currentTimeArray = Array.new()

      results.each { |row|
        if row["arrivingat"] == currentArrivingAt and row["goingto"] == currentGoingTo

          currentTimeArray.push(row["time"])

        else
          formattedResultsRow = [currentArrivingAt, currentGoingTo, currentTimeArray]
          formattedResults.push(formattedResultsRow)
          currentGoingTo = row["goingto"]
          currentArrivingAt = row['arrivingat']
          currentTimeArray = Array.new()
          currentTimeArray.push(row["time"])
        end
      }
      formattedResultsRow = [currentArrivingAt, currentGoingTo, currentTimeArray]
      formattedResults.push(formattedResultsRow)
      return formattedResults
    else
      return nil
    end
    end


    def getSchedule
      if @stations.nil?
        return nil
      else
        search = @stations.prepare("Select * From arrivals")
        results = @stations.execute(search)
        formattedResults = formatResult(results)
        return formattedResults
      end
    end

    def setTrackOperational(arrivingAt, goingTo, isOperational)
      puts isOperational
      if isOperational != 'true'
        neoQuery = "Match (arrivingAt:Station {city:'#{arrivingAt}'})-[t:track]->(goingTo:Station {city:'#{goingTo}'}) Set t.operational = 'true'"
      else
        neoQuery = "Match (arrivingAt:Station {city:'#{arrivingAt}'})-[t:track]->(goingTo:Station {city:'#{goingTo}'}) Set t.operational = 'false'"
      end
      neoArguments = [arrivingAt, goingTo]
      neoDatabase = 'Neo4j'
      Log.addToLog(neoDatabase, neoQuery, neoArguments)
    end

    def getAllRoutes
      begin
        neoQuery = 'Match(n:Station)-[t:track]->(m:Station) Where n.city <> m.city Return Distinct n.city,m.city,t.operational Order By n.city, m.city'
        #neoArguments = []
        #neoDatabase = 'Neo4j'
        #Log.addToLog(neoDatabase, neoQuery, neoArguments)
        results = @neo4j_session.query(neoQuery)
        return results
      rescue Neo4j::Core::CypherSession::ConnectionFailedError
        return nil
      end
    end

    def filterRoutes(arrivingAt, goingTo)
      if @isConnected
        if arrivingAt == "" and goingTo == ""
          return getAllRoutes
        elsif arrivingAt == ""
          neoQuery = 'Match(n:Station)-[t:track]->(m:Station) Where n.city <> m.city and n.city = ? Return Distinct n.city,m.city,t.operational Order By n.city, m.city'
          neoArguments = [arrivingAt]
        elsif goingTo == ""
          neoQuery = 'Match(n:Station)-[t:track]->(m:Station) Where n.city <> m.city and m.city = ? Return Distinct n.city,m.city,t.operational Order By n.city, m.city'
          neoArguments = [goingTo]
        else
          neoQuery = 'Match(n:Station)-[t:track]->(m:Station) Where n.city <> m.city and n.city = ? and m.city = ? Return Distinct n.city,m.city,t.operational Order By n.city, m.city'
          neoArguments = [arrivingAt, goingTo]
        end

        #neoDatabase = 'Neo4j'
        results = @neo4j_session.query(neoQuery, arguments: neoArguments)
        return results
      else
        return nil
      end
    end


    def get_row(arrivingAt, time, goingTo)
      if @stations.nil?
        return nil
      else
        search = @stations.prepare("Select * From arrivals Where arrivingat = ? and time = ? and goingto = ? ALLOW FILTERING;")
        results = @stations.execute(search, arguments: [arrivingAt, time, goingTo])
        return results;
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
        return formatResult(results)
      end
    end

    def findPath(arrivingAt, goingTo)
      if @isConnected
        neoQuery = "Match p = shortestPath((arrivingAt:Station {city: '#{arrivingAt}'})-[t:track*]-(goingTo:Station {city: '#{goingTo}' }))  WHERE ALL (t IN relationships(p) WHERE t.operational='true') return p"
        results = @neo4j_session.query(neoQuery)
        return results
      else
        return nil
      end
    end
  end
