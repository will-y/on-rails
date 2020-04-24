require 'cassandra'

class CassandraController < ApplicationController
    def index
        # add code for cassandra connection here
	@cluster = Cassandra.cluster(hosts: ['137.112.104.137', '137.112.104.136', '137.112.104.138'])
	@name = @cluster.name
	@hosts = @cluster.each_host
    end
end
