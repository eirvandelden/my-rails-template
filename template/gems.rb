# Gem configuration

# Prefer gem.coop (37signals curated source)
gsub_file "Gemfile", /source "https:\/\/rubygems.org"/, 'source "https://gem.coop"'

# bcrypt for has_secure_password
gem "bcrypt"

# Development and test gems
gem_group :development, :test do
  # rubocop-rails-omakase and brakeman are included in Rails 8+ by default
  # Only add if somehow missing
  gem "bundler-audit", require: false
  gem "i18n-tasks"
  gem "faker"
  gem "dotenv-rails"
  gem "capybara"
  gem "selenium-webdriver"
end

gem_group :development do
  gem "letter_opener"
  gem "rack-mini-profiler"
  gem "lefthook"
end

# Production/Performance gems
# Note: thruster is included in Rails 8+ by default
gem "symbol-fstring"

# Data migrations
gem "data_migrate"

# Pagination
gem "geared_pagination"

# I18n - standard Rails translations
gem "rails-i18n"

# Solid Trifecta - included in Rails 8+ by default
# No need to add solid_queue, solid_cache, solid_cable

# Mission Control for monitoring jobs (commented out - brings Bulma CSS)
# gem "mission_control-jobs"

# Image processing (uncomment if needed)
# gem "image_processing"

# Markdown rendering (uncomment if needed)
# gem "redcarpet"
# gem "rouge"
