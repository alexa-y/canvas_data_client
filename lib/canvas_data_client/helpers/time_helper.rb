module CanvasDataClient::Helpers::TimeHelper

  def rfc7231(time)
    time.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
  end
end
