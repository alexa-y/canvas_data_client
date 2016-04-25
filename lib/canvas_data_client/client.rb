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
      paginated_request "#{domain}/api/account/#{account}/dump?after=%s"
    end

    def dump(dump_id)
      json_request "#{domain}/api/account/#{account}/file/byDump/#{dump_id}"
    end

    def tables(table)
      paginated_request "#{domain}/api/account/#{account}/file/byTable/#{table}?after=%s"
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

    def paginated_request(path)
      received = []
      sequence = '0'
      loop do
        resp = json_request(path % sequence)
        resp = resp['history'] if resp.is_a?(Hash)
        resp.sort_by! { |h| h['sequence'] }
        received += resp
        break if resp.length < 50
        sequence = resp.last['sequence']
      end
      received
    end

  end
end
