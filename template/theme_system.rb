# Theme switching system - JavaScript and helpers

say "Setting up theme switching system...", :blue

# Create theme helper
create_file "app/helpers/theme_helper.rb", <<~RUBY
  module ThemeHelper
    def theme_attributes
      if Current.user
        {
          "data-color-scheme": Current.user.color_scheme,
          "light-theme": Current.user.light_theme,
          "dark-theme": Current.user.dark_theme
        }
      else
        # Defaults for guests: system color scheme, selenized themes
        {
          "data-color-scheme": "system",
          "light-theme": "selenized_light",
          "dark-theme": "selenized_dark"
        }
      end
    end
  end
RUBY

# Create Stimulus controller for theme switching
create_file "app/javascript/controllers/theme_controller.js", <<~JS
  import { Controller } from "@hotwired/stimulus"

  export default class extends Controller {
    connect() {
      this.applyTheme()
    }

    applyTheme() {
      const colorScheme = this.element.dataset.colorScheme
      const lightTheme = this.element.getAttribute("light-theme")
      const darkTheme = this.element.getAttribute("dark-theme")

      // Apply theme based on color scheme preference
      if (colorScheme === "system") {
        // Use system preference
        const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
        this.setTheme(prefersDark ? darkTheme : lightTheme, prefersDark)
      } else if (colorScheme === "dark") {
        this.setTheme(darkTheme, true)
      } else {
        this.setTheme(lightTheme, false)
      }
    }

    setTheme(theme, isDark) {
      const html = document.documentElement

      if (isDark) {
        html.setAttribute("dark-theme", theme)
        html.removeAttribute("light-theme")
      } else {
        html.setAttribute("light-theme", theme)
        html.removeAttribute("dark-theme")
      }
    }
  }
JS

say "✓ Theme switching system installed", :green
