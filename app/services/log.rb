require 'cassandra'
require 'neo4j/core/cypher_session/adaptors/http'
require 'yaml'

class Log

  def self.addToLog(database, query, arguments)

    File.write("log.txt", "#{database}##{query}##{arguments.join(",")}\n", mode: "a")
  end

  def self.add_to_mongo_log(database, object, method)
    File.write("log.txt", "#{database}##{object.id}##{method}\n", mode: "a")
    File.open(object.id.to_s + ".bin", "wb") { |file| file.write(Marshal.dump(object)) }
  end

  def self.mongo_log
    if File.file?("log.txt")
      puts "-----------------"
      puts File.read("log.txt")
      failed = false
      tmp = ""
      File.foreach("log.txt") do |line|

        if failed
          tmp = tmp + line
        else

          line = line.split("#")
          #object = YAML.load(File.read(line[0] + ".yml"))
          object = Marshal.load(File.binread(line[1] + ".bin"))

          begin
            if !object.send(line[2].strip)
              failed = true
              tmp = tmp + line.join("#")
            else
              `rm #{line[1]}.bin`
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
    if File.file?("log.txt")
      puts "-----------------"
      puts File.read("log.txt")
      failed = false
      tmp = ""
      File.foreach("log.txt") do |line|
        if failed
          tmp = tmp + line
        else
          line = line.split("#")
          databaseName = line[0]
          query = line[1]
          arguments = line[2].split(",")
          arguments = arguments.collect {|a| a.starts_with?("DECIMAL_") ? a[8..-1].to_d : a}

          if databaseName == "Cassandra"
            result = self.cassandraQuery(query, arguments)
            if result == "error"
              failed = true
              tmp = tmp + line.join("#")
            end
          elsif databaseName == "Neo4j"
            result = self.neo4jQuery(query, arguments)
            if result == "error"
              failed = true
              tmp = tmp + line.join("#")
            end
          elsif databaseName == "Mongo"
            object = Marshal.load(File.binread(line[1] + ".bin"))

            begin
              if !object.send(line[2].strip)
                failed = true
                tmp = tmp + line.join("#")
              else
                `rm #{line[1]}.bin`
              end
            rescue
              failed = true
              tmp = tmp + line.join("#")
            end
          end
        end
      end
      File.write("log.txt", tmp)
    end
  end

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

  def self.neo4jQuery(query, arguments)
    begin
      http_adaptor = Neo4j::Core::CypherSession::Adaptors::HTTP.new('http://neo4j:Onrails433@137.112.104.139:7474')
      neo4j_session = Neo4j::Core::CypherSession.new(http_adaptor)
      connected = http_adaptor.connected?
      results = neo4j_session.query(query)
      if not connected
        return "error"
      else
        return results;
      end
    rescue Neo4j::Core::CypherError::NoHostsAvailable
      return "error"
    end
  rescue Neo4j::Core::CypherSession::ConnectionFailedError
    return "error"
  end
end

