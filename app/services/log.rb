require 'cassandra'
require 'neo4j/core/cypher_session/adaptors/http'

class Log
  @@log = Array.new
  #puts("Log Created")

  #def initialize
  #  goThroughLog
  #end

  #Things are isnerted like this:
  # procedure to return result to <- this is the new end of the array
  # arguments
  # query
  # database
  # Old end of the array
  #
  def self.addToLog(database, query, arguments, procedure)

    @@log.push(database)
    @@log.push(query)
    @@log.push(arguments)
    @@log.push(procedure)
    #puts(@@log)
    goThroughLog
  end


  def self.goThroughLog
    #puts("Started Log")
    #puts(@@log)
    while @@log.length!=0
      #if @@log.length != 0
      puts(@@log)
      databaseName = @@log[0]
      query = @@log[1]
      arguments = @@log[2]
      procedure = @@log[3]
      if databaseName == "Cassandra"
        result = cassandraQuery(query, arguments)
        if result != "error"
          procedure.call(result)
          @@log.shift(4)
          return result
        end
      elsif databaseName == "Neo4j"
        result = neo4jQuery(query, arguments)
        if result != "error"
          procedure.call(result)
          @@log.shift(4)
          return result
        end
      elsif databaseName == "MongoDB"
        result = mongoQuery(query, arguments)
        if result != "error"
          procedure.call(result)
          @@log.shift(4)
          return result
        end
      end
    end
    #puts("LOG waiting before sleep")
    #puts(@@log)
    #sleep(1)
    #puts("LOG waiting")
  end

  #end


  def self.cassandraQuery(query, arguments)
    begin
      cluster = Cassandra.cluster(hosts: %w[137.112.104.137 137.112.104.136 137.112.104.138])
      stations = cluster.connect("stations")
      statement = stations.prepare(query)
      results = stations.execute(statement, arguments: arguments)
      return results;
    rescue Cassandra::Errors::NoHostsAvailable => e
      return "error"
    end
  end

  def self.mongoQuery(query, arguments)
    begin
      results = query.call(arguments)
      return results;
    rescue NoHostsAvailable
      return "error"
    end
  end

  def self.neo4jQuery(query, arguments)
    begin
      http_adaptor = Neo4j::Core::CypherSession::Adaptors::HTTP.new('http://neo4j:pass@localhost:7474')
      neo4j_session = Neo4j::Core::CypherSession.new(http_adaptor)
      connected = http_adaptor.connected?
      results = neo4j_session.query(query)
      if not connected
        return "error"
      else
        return results;
      end
    rescue NoHostsAvailable
      return "error"
    end
  end

end
#Log.goThroughLog

