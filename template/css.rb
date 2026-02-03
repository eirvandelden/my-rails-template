# CSS setup with classless approach and Selenized OKLCH colors
# SMACSS architecture with folder structure loaded via stylesheet_link_tag :all

say "Setting up classless CSS with Selenized themes...", :blue

remove_file "app/assets/stylesheets/application.css"

# Get the template directory path
css_dir = File.join(TEMPLATE_ROOT, "css")

# SMACSS folder structure:
# 0_settings/ - Colors, variables (no CSS output, just custom properties)
# 1_base/     - Reset, typography, tables, forms, details
# 2_layout/   - Header, main, footer
# 3_components/ - Flash, errors, buttons, progress, etc.
# 4_themes/   - Theme switching logic

# Copy entire CSS folder structure
Dir.glob(File.join(css_dir, "**", "*.css")).sort.each do |source_file|
  # Get relative path from css_dir
  relative_path = source_file.sub("#{css_dir}/", "")
  target_path = "app/assets/stylesheets/#{relative_path}"

  content = File.read(source_file)
  create_file target_path, content
  say "  ✓ Created #{relative_path}", :green
end

say "✓ Classless CSS system installed (SMACSS)", :green
say "  - 0_settings: OKLCH colors, CSS variables", :white
say "  - 1_base: Reset, typography, tables, forms", :white
say "  - 2_layout: Header, main, footer", :white
say "  - 3_components: Flash, errors, buttons, etc.", :white
say "  - 4_themes: Theme switching logic", :white
say "  - Loaded via stylesheet_link_tag :all", :white
