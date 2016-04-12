require 'rest-client'

module CanvasDataClient
  class Client
    include CanvasDataClient::Helpers::HMACHelper
    include CanvasDataClient::Helpers::CsvHelper

    attr_accessor :key, :secret, :subdomain, :account

    def initialize(key, secret, opts = {})
      self.key = key
      self.secret = secret
      self.subdomain = opts[:subdomain] || 'portal'
      self.account = opts[:account] || 'self'
    end

    def domain
      "https://#{subdomain}.inshosteddata.com"
    end

    def latest_files
      json_request "#{domain}/api/account/#{account}/file/latest"
    end
    alias_method :latest, :latest_files

    def dumps
      retrieved_dumps = []
      sequence = '0'
      loop do
        resp = json_request "#{domain}/api/account/#{account}/dump?after=#{sequence}"
        retrieved_dumps += resp
        break if resp.length < 50
        sequence = resp.last['sequence']
      end
      retrieved_dumps
    end

    def dump(dump_id)
      json_request "#{domain}/api/account/#{account}/file/byDump/#{dump_id}"
    end

    def tables(table)
      retrieved_tables = []
      sequence = '0'
      loop do
        resp = json_request "#{domain}/api/account/#{account}/file/byTable/#{table}?after=#{sequence}"
        retrieved_tables += resp['history']
        break if resp['history'].length < 50
        sequence = resp['history'].last['sequence']
      end
      retrieved_tables
    end

    def schemas
      json_request "#{domain}/api/schema"
    end

    def latest_schema
      json_request "#{domain}/api/schema/latest"
    end

    def schema(version)
      json_request "#{domain}/api/schema/#{version}"
    end

    private
    def json_request(path, method = 'get')
      resp = RestClient.get path, headers(key, secret, { path: path, method: method })
      JSON.parse resp
    end

  end
end
