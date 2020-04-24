require 'cassandra'
require 'neo4j/core/cypher_session/adaptors/http'

class CassandraController < ApplicationController
    def index
        # add code for cassandra connection here
	@cluster = Cassandra.cluster(hosts: ['137.112.104.137', '137.112.104.136', '137.112.104.138'])
	@name = @cluster.name
	@hosts = @cluster.each_host

	# code for neo4j connections
	@http_adaptor = Neo4j::Core::CypherSession::Adaptors::HTTP.new('http://neo4j:pass@localhost:7474')
	@neo4j_session = Neo4j::Core::CypherSession.new(@http_adaptor)
	@connected = @http_adaptor.connected?
    end
end
