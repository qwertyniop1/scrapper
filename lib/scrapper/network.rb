require 'curb'
require 'timeout'

require_relative 'null_logger'

def get_html(url)
  http = Curl.get(url)
  raise ArgumentError, 'Invalid url' unless http.status.split.first.to_i == 200
  return http.body_str
end

def fetch(url, tries, timeout, logger = nil)
  logger ||= NullLogger.new
  logger.info "Fetching HTML from #{url}"

  tries.times do |index|
    begin
      Timeout.timeout(timeout) do
        return get_html(url)
      end
    rescue Curl::Err::HostResolutionError
      pause = (index + 1)**2
      logger.debug "Network error! Trying to recieve data in #{pause} seconds..."
      sleep(pause)
    rescue Timeout::Error
      logger.debug 'Response timeout exceeded!'
      break
    rescue ArgumentError => error
      logger.debug error.message
      break
    end
  end

  logger.error "Could not resolve #{url}"
  nil
end
