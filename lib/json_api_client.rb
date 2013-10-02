require 'faraday'
require 'faraday_middleware'
require 'json'

module JsonApiClient
  autoload :Parser, 'json_api_client/parser'
  autoload :Query, 'json_api_client/query'
  autoload :Resource, 'json_api_client/resource'
  autoload :ResultSet, 'json_api_client/result_set'
  autoload :Scope, 'json_api_client/scope'
end