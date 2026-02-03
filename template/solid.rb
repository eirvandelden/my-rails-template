# Solid Trifecta installation

say "Installing Solid Queue...", :blue
rails_command "solid_queue:install"

say "Installing Solid Cache...", :blue
rails_command "solid_cache:install"

say "Installing Solid Cable...", :blue
rails_command "solid_cable:install"

# Mission Control removed - brings Bulma CSS which conflicts with classless approach
# If you need job monitoring, use the Rails console or add a custom admin page
