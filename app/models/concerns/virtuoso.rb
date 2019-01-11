module Virtuoso
  extend ActiveSupport::Concern
  require 'httpclient'
  def auth_query(sparqlquery)
    #    uri = 'http://localhost:8890/sparql-auth'
    uri = 'http://lod.srmt.nitech.ac.jp/sparql-auth'
    client = HTTPClient.new
    user = 'dba'
    # password = 'dba'
    password = 'srmt1ab'
    # client.set_auth('http://localhost:8890/', user, password)
    client.set_auth('http://lod.srmt.nitech.ac.jp/', user, password)
    clireturn = client.get(uri, :query => {:query => sparqlquery, :format => 'application/sparql-results+json'})

    return clireturn
  end
end
