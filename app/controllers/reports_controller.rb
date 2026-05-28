class ReportsController < ApplicationController
  include GumshoeApiUrls
  
  def index
    @curl_command = curl_command(reports_url)
    
    begin
      credentials = Rails.application.credentials      
      gumshoe_creds = credentials.gumshoe
      api_key = gumshoe_creds[:api_key]
      
      @curl_command = curl_command(reports_url)
      
      client = GumshoeClient.new(api_key)
      response = client.reports
      @curl_command = client.curl_command
      
      if response.success?
        parsed = response.parsed_response
        # Handle nested structure: {"data": [...]}, {"reports": [...]} or direct array
        @reports = if parsed.is_a?(Hash) && parsed['data']
          parsed['data']
        elsif parsed.is_a?(Hash) && parsed[:data]
          parsed[:data]
        elsif parsed.is_a?(Hash) && parsed['reports']
          parsed['reports']
        elsif parsed.is_a?(Hash) && parsed[:reports]
          parsed[:reports]
        elsif parsed.is_a?(Array)
          parsed
        else
          [parsed]
        end
      else
        @reports = []
        @error = "Failed to fetch reports: HTTP #{response.code} - #{response.message}"
        Rails.logger.error @error
        Rails.logger.error "Response body: #{response.body}"
      end
    rescue => e
      @reports = []
      @error = "Error fetching reports: #{e.class} - #{e.message}"
      Rails.logger.error "Exception: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      # @curl_command is already set at the top of the method, so it will always be available
    end
  end
  
  def show
    begin
      api_key = Rails.application.credentials.gumshoe[:api_key]
      client = GumshoeClient.new(api_key)
      response = client.report(params[:id])
      @curl_command = client.curl_command
      
      if response.success?
        parsed = response.parsed_response
        # Handle nested structure: {"data": {...}}, {"report": {...}} or direct object
        @report = if parsed.is_a?(Hash) && parsed['data']
          parsed['data']
        elsif parsed.is_a?(Hash) && parsed[:data]
          parsed[:data]
        elsif parsed.is_a?(Hash) && parsed['report']
          parsed['report']
        elsif parsed.is_a?(Hash) && parsed[:report]
          parsed[:report]
        else
          parsed
        end
        # Extract runs from the report response
        @runs = if @report.is_a?(Hash)
          @report['runs'] || @report[:runs] || []
        else
          []
        end
      else
        @error = "Failed to fetch report: HTTP #{response.code} - #{response.message}"
        Rails.logger.error @error
        Rails.logger.error "Response body: #{response.body}"
        redirect_to reports_path, alert: @error
      end
    rescue => e
      @error = "Error fetching report: #{e.message}"
      Rails.logger.error "Exception: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to reports_path, alert: @error
    end
  end
end
