# Theme switching system - JavaScript and helpers

say "Setting up theme switching system...", :blue

# Create theme helper
create_file "app/helpers/theme_helper.rb", <<~RUBY
  module ThemeHelper
    def theme_attributes
      return {} unless Current.user

      # Only set data-theme when user has explicitly chosen non-system
      # CSS handles system preference via prefers-color-scheme
      case Current.user.color_scheme
      when "light"
        { "data-theme": Current.user.light_theme }
      when "dark"
        { "data-theme": Current.user.dark_theme }
      else
        # System preference - let CSS handle it, no data-theme needed
        {}
      end
    end
  end
RUBY

# Create Stimulus controller for theme switching (handles live preference changes)
create_file "app/javascript/controllers/theme_controller.js", <<~JS
  import { Controller } from "@hotwired/stimulus"

  // This controller is optional - CSS handles prefers-color-scheme automatically
  // It's only needed if you want to support theme toggling without page reload
  export default class extends Controller {
    static values = {
      colorScheme: { type: String, default: "system" },
      lightTheme: { type: String, default: "selenized_light" },
      darkTheme: { type: String, default: "selenized_dark" }
    }

    connect() {
      // Only apply if user has explicitly set a preference
      if (this.colorSchemeValue !== "system") {
        this.applyTheme()
      }
    }

    applyTheme() {
      if (this.colorSchemeValue === "light") {
        this.element.dataset.theme = this.lightThemeValue
      } else if (this.colorSchemeValue === "dark") {
        this.element.dataset.theme = this.darkThemeValue
      } else {
        // System - remove override, let CSS handle it
        delete this.element.dataset.theme
      }
    }
  }
JS

say "✓ Theme switching system installed", :green
