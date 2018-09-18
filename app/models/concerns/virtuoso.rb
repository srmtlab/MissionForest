module Virtuoso
  extend ActiveSupport::Concern
  require 'httpclient'
  def auth_query(sparqlquery)
    uri = 'http://localhost:8890/sparql-auth'
    client = HTTPClient.new
    user = 'dba'
    password = 'dba'
    client.set_auth('http://localhost:8890/', user, password)
    clireturn = client.get(uri, :query => {:query => sparqlquery, :format => 'application/sparql-results+json'})

    return clireturn
  end
end
