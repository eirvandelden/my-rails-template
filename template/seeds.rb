# Database seeds

# Create seed data with admin and regular user
gsub_file "db/seeds.rb", /.*/m, <<~RUBY
  # Create admin user
  admin = User.find_or_create_by!(email: "etienne@localhost") do |user|
    user.password = "Testtest1"
    user.password_confirmation = "Testtest1"
    user.role = :admin
    user.locale = "nl"
  end
  puts "Created admin user: etienne@localhost / Testtest1"

  # Create regular user
  user = User.find_or_create_by!(email: "user@localhost") do |user|
    user.password = "Testtest1"
    user.password_confirmation = "Testtest1"
    user.role = :user
    user.locale = "en"
  end
  puts "Created regular user: user@localhost / Testtest1"

  # Optional: Load private seeds (for local development, sensitive data)
  private_seeds = Rails.root.join("db", "seeds_private.rb")
  if File.exist?(private_seeds)
    puts "Loading private seeds..."
    load private_seeds
  end
RUBY

# Create example seeds_private.rb file
create_file "db/seeds_private.rb.example", <<~RUBY
  # Private seeds file for sensitive or local-only data
  # Copy this file to db/seeds_private.rb and customize
  # This file is gitignored and won't be committed

  # Example:
  # user = User.find_or_create_by!(email: "local@example.com") do |u|
  #   u.password = "secure_password"
  #   u.role = :admin
  # end
RUBY

# Add private seeds to gitignore
append_to_file ".gitignore", "\n# Private seeds (local development only)\n/db/seeds_private.rb"
