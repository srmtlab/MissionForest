#############################################
# Stardogクライアント
#############################################

require 'stardog'
include Stardog

module Clients
  class Stardog

    def initialize(user="admin", password="admin", database="MissionForest")
      @stardog = stardog("http://localhost:5820/",
        :user => user,
        :password => password,
        :reasoning => "QL"
      )
      @database = database
    end

    def new_db(name)
      @stardog.create_db(name)
    end

    def destroy_db(name)
      @stardog.drop_db(name)
    end

    def new_user(username, password)
      system("#{ENV['STARDOG_HOME']}/bin/stardog-admin user add #{username} -N #{password}")
    end

    def add_triples(triples=[])
      @stardog.add(@database, triples.join(' '))
    end

    def destroy_triple(url="")
         @stardog.remove(@database, url, nil, "application/rdf+xml")
    end

    def find
     @stardog.query(@database, "select distinct ?o where { <http://linkdata.org/resource/rdf1s258i#%E5%90%8D%E5%8F%A4%E5%B1%8B%E5%9F%8E> ?p ?o }").body["results"]["bindings"]
    end
  end
end
