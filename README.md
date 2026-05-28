# Gumshoe API Rails Application

A Rails application for viewing reports and report runs from the Gumshoe API.

## Features

- View list of reports from Gumshoe API
- View individual report details
- View list of report runs from Gumshoe API
- View individual report run details
- HAML templates for clean, readable views
- Secure API key storage using Rails encrypted credentials

## Setup

### Prerequisites

- Ruby 3.4.5 or compatible
- Rails 8.1.0
- Bundler

### Installation

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Set up the master key for encrypted credentials:
   
   The master key file (`config/master.key`) should already exist. If it doesn't, you can generate one:
   ```bash
   openssl rand -hex 32 > config/master.key
   ```
   
   **Important**: Never commit the `config/master.key` file to version control!

3. Set up encrypted credentials with the Gumshoe API key:
   ```bash
   EDITOR="nano" bin/rails credentials:edit
   ```
   
   Add the following content:
   ```yaml
   gumshoe:
     api_key: your_gumshoe_api_key
   ```
   
   Save and close the editor. Rails will encrypt and save the credentials.

4. Set up the database (if using ActiveRecord features):
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   ```

5. Start the Rails server:
   ```bash
   bin/rails server
   ```

6. Visit `http://localhost:3000` in your browser.

## Routes

- `/` - Root path (redirects to reports index)
- `/reports` - List all reports
- `/reports/:id` - Show a specific report
- `/report_runs` - List all report runs
- `/report_runs/:id` - Show a specific report run

## API Integration

The application uses the Gumshoe API at `https://app.gumshoe.ai/openapi`. The API client is located in `app/services/gumshoe_client.rb` and handles:

- Fetching all reports
- Fetching a specific report by ID
- Fetching all report runs
- Fetching a specific report run by ID

## Security

- API keys are stored in Rails encrypted credentials (`config/credentials.yml.enc`)
- The master key (`config/master.key`) is excluded from version control
- Never commit sensitive credentials to the repository

## Technology Stack

- **Rails 8.1.0** - Web framework
- **HAML** - Template engine
- **HTTParty** - HTTP client for API calls
- **SQLite3** - Database (if needed)

## Development

To view or edit credentials:
```bash
EDITOR="nano" bin/rails credentials:edit
```

To view credentials in the console:
```ruby
Rails.application.credentials.gumshoe[:api_key]
```
