# Solid Trifecta installation

say "Installing Solid Queue...", :blue
rails_command "solid_queue:install"

say "Installing Solid Cache...", :blue
rails_command "solid_cache:install"

say "Installing Solid Cable...", :blue
rails_command "solid_cable:install"

# Mount Mission Control - no install command needed, just mount it
say "Mounting Mission Control Jobs...", :blue
route 'mount MissionControl::Jobs::Engine, at: "/jobs"'
