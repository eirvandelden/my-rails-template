# CSS setup with classless approach and Selenized OKLCH colors
# SMACSS architecture with separate files loaded via stylesheet_link_tag :all

say "Setting up classless CSS with Selenized themes...", :blue

remove_file "app/assets/stylesheets/application.css"

# Get the template directory path
css_dir = File.join(TEMPLATE_ROOT, "css")

# Copy all CSS files - SMACSS organization
css_files = %w[
  application.css
  colors.css
  variables.css
  base.css
  forms.css
  layout.css
  components.css
  themes.css
]

css_files.each do |file|
  source_file = File.join(css_dir, file)
  if File.exist?(source_file)
    content = File.read(source_file)
    create_file "app/assets/stylesheets/#{file}", content
    say "  ✓ Created #{file}", :green
  else
    say "  ✗ Warning: CSS file not found: #{source_file}", :red
  end
end

say "✓ Classless CSS system installed (SMACSS)", :green
say "  - OKLCH Selenized colors (4 themes)", :white
say "  - 37signals spacing system (1ch × 1rem)", :white
say "  - Semantic HTML styling (minimal classes)", :white
say "  - Responsive design (mobile-first)", :white
say "  - Theme switching support", :white
say "  - Loaded via stylesheet_link_tag :all", :white
