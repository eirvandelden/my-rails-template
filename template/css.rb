# CSS setup with MVPA.css framework
# See: https://github.com/eirvandelden/mvpa.css

say "Setting up MVPA.css framework...", :blue

remove_file "app/assets/stylesheets/application.css"

# MVPA.css is installed as a gem and provides:
# 0_settings/ - Colors, variables (OKLCH Selenized colors, 37signals spacing)
# 1_base/     - Reset, typography, tables, forms, details
# 2_layout/   - Header, main, footer
# 3_components/ - Flash, errors, buttons, progress, etc.
# 4_themes/   - Theme switching logic

# Create application.css that imports MVPA.css
create_file "app/assets/stylesheets/application.css", <<~CSS
  /*
   * MVPA.css framework
   * https://github.com/eirvandelden/MVPA.css
   *
   * This imports all MVPA.css components in the correct order:
   * 0_settings → 1_base → 2_layout → 3_components → 4_themes
   */
  @import "mvpa/mvpa";

  /*
   * Add your local CSS customizations below
   * Use CSS custom properties to override MVPA.css defaults:
   *
   * :root {
   *   --inline-space: 1.5ch;
   *   --block-space: 1.5rem;
   * }
   */
CSS

say "✓ MVPA.css framework installed", :green
say "  - Framework: MVPA.css gem (https://github.com/eirvandelden/mvpa.css)", :white
say "  - 0_settings: OKLCH Selenized colors, CSS variables", :white
say "  - 1_base: Reset, typography, tables, forms", :white
say "  - 2_layout: Header, main, footer", :white
say "  - 3_components: Flash, errors, buttons, etc.", :white
say "  - 4_themes: Theme switching logic", :white
say "  - Loaded via @import in application.css", :white
