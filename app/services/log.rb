require 'cassandra'
require 'neo4j/core/cypher_session/adaptors/http'
require 'yaml'

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

  def self.add_to_mongo_log(object, method)
    File.write("log.txt", "#{object.id}##{method}\n", mode: "a")
    File.open(object.id.to_s + ".bin", "wb") { |file| file.write(Marshal.dump(object)) }
  end

  def self.mongo_log
    if File.file?("log.txt")
      puts "----------------------"
      puts File.read("log.txt")
      failed = false
      tmp = ""
      File.foreach("log.txt") do |line|

        if failed
          tmp = tmp + line
        else

          line = line.split("#")
          #object = YAML.load(File.read(line[0] + ".yml"))
          object = Marshal.load(File.binread(line[0] + ".bin"))

          begin
            if !object.send(line[1].strip)
              failed = true
              tmp = tmp + line.join("#")
            else
              `rm #{line[0]}.bin`
            end
          rescue
            failed = true
            tmp = tmp + line.join("#")
          end
        end
      end
      File.write("log.txt", tmp)
    end
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

