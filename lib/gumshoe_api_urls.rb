module GumshoeApiUrls
  API_VERSION = 'v1'
  
  module_function
  
  def base_uri
    @base_uri ||= begin
      if defined?(Rails) && Rails.application.credentials.gumshoe&.dig(:api_url)
        Rails.application.credentials.gumshoe[:api_url]
      else
        'https://app.gumshoe.ai' # fallback default
      end
    end
  end
  
  def reports_url
    "/#{API_VERSION}/reports"
  end
  
  def report_url(id)
    "/#{API_VERSION}/reports/#{id}"
  end
  
  def report_runs_url(report_id)
    "/#{API_VERSION}/reports/#{report_id}/runs"
  end
  
  def report_run_url(report_id, ordinal)
    "/#{API_VERSION}/reports/#{report_id}/runs/#{ordinal}"
  end
  
  def report_run_raw_url(report_id, ordinal)
    "/#{API_VERSION}/reports/#{report_id}/runs/#{ordinal}/raw"
  end
  
  def full_url(path)
    "#{base_uri}#{path}"
  end
  
  def curl_command(path)
    full = full_url(path)
    "curl -X GET '#{full}' -H 'Authorization: Bearer <GUMSHOE_API_KEY>' -H 'Content-Type: application/json' -v"
  end
end
