require 'base64'

module CanvasDataClient::Helpers::HMACHelper
  include ::CanvasDataClient::Helpers::TimeHelper

  def compute_signature(secret, time, opts = {})
    message = build_message(secret, rfc7231(time), opts)
    digest = OpenSSL::Digest.new('sha256')
    signature = OpenSSL::HMAC.digest(digest, secret, message)
    Base64.encode64(signature).strip
  end

  def headers(key, secret, opts = {})
    raise 'A url must be defined as :path in opts' unless opts[:path]
    opts[:method] ||= 'get'
    opts[:content_type] ||= 'application/json'
    time = Time.now
    signature = compute_signature(secret, time, opts)
    {
      'Authorization' => "HMACAuth #{key}:#{signature}",
      'Date' => rfc7231(time),
      'Content-Type' => opts[:content_type]
    }
  end

  private
  def build_message(secret, time_string, opts = {})
    uri = URI(opts[:path])
    sorted_params = uri.query ? uri.query.split(/&/).sort : []
    parts = [
      opts[:method].upcase,
      uri.host,
      opts[:content_type] || '',
      opts[:content_md5] || '',
      uri.path,
      sorted_params.join('&'),
      time_string,
      secret
    ]
    parts.join("\n")
  end
end
