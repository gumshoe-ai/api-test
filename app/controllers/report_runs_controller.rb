class ReportRunsController < ApplicationController
  include GumshoeApiUrls

  before_action :set_report_id

  def index
    @curl_command = curl_command(report_runs_url(@report_id))

    begin
      # Check if credentials are available - wrap in rescue in case master key is missing
      credentials = nil
      begin
        credentials = Rails.application.credentials
      rescue => cred_error
        @error = "Cannot access credentials: #{cred_error.message}. Check config/master.key exists."
        @report_runs = []
        Rails.logger.error @error
        Rails.logger.error "Credentials error: #{cred_error.class} - #{cred_error.message}"
        return
      end

      if credentials.nil?
        @error = "Credentials not available. Check config/master.key and config/credentials.yml.enc"
        @report_runs = []
        Rails.logger.error @error
        return
      end

      gumshoe_creds = credentials.gumshoe
      if gumshoe_creds.nil?
        @error = "Gumshoe credentials not found in credentials file. Run: EDITOR='nano' bin/rails credentials:edit"
        @report_runs = []
        Rails.logger.error @error
        return
      end

      api_key = gumshoe_creds[:api_key]
      if api_key.blank?
        @error = "API key is blank. Check credentials file."
        @report_runs = []
        Rails.logger.error @error
        return
      end

      @curl_command = curl_command(report_runs_url(@report_id))

      client = GumshoeClient.new(api_key)
      response = client.report_runs(@report_id, gumshoe_pagination_params)
      @curl_command = client.curl_command

      if response.success?
        parsed = response.parsed_response
        set_gumshoe_pagination(parsed)
        # Handle nested structure: {"data": [...]}, {"runs": [...]} or direct array
        @report_runs = if parsed.is_a?(Hash) && parsed["data"]
          parsed["data"]
        elsif parsed.is_a?(Hash) && parsed[:data]
          parsed[:data]
        elsif parsed.is_a?(Hash) && parsed["runs"]
          parsed["runs"]
        elsif parsed.is_a?(Hash) && parsed[:runs]
          parsed[:runs]
        elsif parsed.is_a?(Array)
          parsed
        else
          [ parsed ]
        end
      else
        @report_runs = []
        @error = "Failed to fetch report runs: HTTP #{response.code} - #{response.message}"
        Rails.logger.error @error
        Rails.logger.error "Response body: #{response.body}"
      end
    rescue => e
      @report_runs = []
      @error = "Error fetching report runs: #{e.class} - #{e.message}"
      Rails.logger.error "Exception: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      # @curl_command is already set at the top of the method, so it will always be available
    end
  end

  def show
    begin
      api_key = Rails.application.credentials.gumshoe[:api_key]
      client = GumshoeClient.new(api_key)
      ordinal = params[:ordinal] || params[:id]
      response = client.report_run(@report_id, ordinal)
      @curl_command = client.curl_command

      if response.success?
        @report_run = response.parsed_response
      else
        @error = "Failed to fetch report run: HTTP #{response.code} - #{response.message}"
        Rails.logger.error @error
        Rails.logger.error "Response body: #{response.body}"
        redirect_to report_runs_path(report_id: @report_id), alert: @error
      end
    rescue => e
      @error = "Error fetching report run: #{e.message}"
      Rails.logger.error "Exception: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to report_runs_path(report_id: @report_id), alert: @error
    end
  end

  def raw
    begin
      api_key = Rails.application.credentials.gumshoe[:api_key]
      client = GumshoeClient.new(api_key)
      ordinal = params[:ordinal] || params[:id]
      response = client.report_run_raw(@report_id, ordinal)
      @curl_command = client.curl_command

      if response.success?
        @raw_data = response.body
        render plain: @raw_data, content_type: "application/json"
      else
        @error = "Failed to fetch raw report run: HTTP #{response.code} - #{response.message}"
        Rails.logger.error @error
        Rails.logger.error "Response body: #{response.body}"
        redirect_to report_run_path(report_id: @report_id, ordinal: ordinal), alert: @error
      end
    rescue => e
      @error = "Error fetching raw report run: #{e.message}"
      Rails.logger.error "Exception: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to report_run_path(report_id: @report_id, ordinal: ordinal), alert: @error
    end
  end

  private

  def set_report_id
    @report_id = params[:report_id]
  end
end
