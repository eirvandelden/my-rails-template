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
RUBY
