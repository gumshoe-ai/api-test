require 'httparty'

class GumshoeClient
  include HTTParty
  include GumshoeApiUrls
  
  def initialize(api_key)
    @api_key = api_key
    @curl_command = nil
    @base_uri = GumshoeApiUrls.base_uri
    self.class.base_uri @base_uri
    @options = {
      headers: {
        'Authorization' => "Bearer #{api_key}",
        'Content-Type' => 'application/json'
      }
    }
  end
  
  attr_reader :curl_command
  
  def reports
    url = reports_url
    log_request(url)
    response = self.class.get(url, @options)
    log_response(response, url)
    response
  end
  
  def report(id)
    url = report_url(id)
    log_request(url)
    response = self.class.get(url, @options)
    log_response(response, url)
    response
  end
  
  def report_runs(report_id)
    url = report_runs_url(report_id)
    log_request(url)
    response = self.class.get(url, @options)
    log_response(response, url)
    response
  end
  
  def report_run(report_id, ordinal)
    url = report_run_url(report_id, ordinal)
    log_request(url)
    response = self.class.get(url, @options)
    log_response(response, url)
    response
  end
  
  def report_run_raw(report_id, ordinal)
    url = report_run_raw_url(report_id, ordinal)
    log_request(url)
    response = self.class.get(url, @options)
    log_response(response, url)
    response
  end
  
  private
  
  def log_request(url)
    @curl_command = GumshoeApiUrls.curl_command(url)
  end
  
  def log_response(response, url)
    # Only log errors
    if response.code >= 400
      complete_url = GumshoeApiUrls.full_url(url)
      Rails.logger.error "Gumshoe API Error: #{complete_url} - HTTP #{response.code} - #{response.message}"
      Rails.logger.error "Response body: #{response.body}"
    end
  end
end
