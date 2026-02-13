# CSS System Guide

This template uses **[MVPA.css](https://github.com/eirvandelden/MVPA.css)** - a classless CSS framework with OKLCH Selenized colors, SMACSS architecture, and theme switching.

See the [MVPA.css repository](https://github.com/eirvandelden/MVPA.css) for framework documentation.

## SMACSS Structure

MVPA.css is organized using SMACSS (Scalable and Modular Architecture for CSS):

- `0_settings/` - Colors, variables (OKLCH Selenized colors, spacing)
- `1_base/` - Reset, typography, tables, forms, details
- `2_layout/` - Header, main, footer
- `3_components/` - Flash, errors, buttons, progress, etc.
- `4_themes/` - Theme switching logic

## Usage

### Installation

MVPA.css is installed as a gem:

```ruby
# Gemfile
gem "mvpa-css", github: "eirvandelden/mvpa.css"
```

Generated apps include it via `app/assets/stylesheets/application.css`:

```css
@import "mvpa/mvpa";
```

### Updating

```bash
bundle update mvpa-css
```

### Customization

Add your CSS after the MVPA.css import in `application.css`:

```css
@import "mvpa/mvpa";

/* Your customizations */
:root {
  --inline-space: 1.5ch;
}
```

For larger customizations, create separate CSS files:

```css
/* app/assets/stylesheets/application.css */
@import "mvpa/mvpa";
@import "local/custom";
```

## Theme System

The template integrates MVPA.css themes with user preferences via the User model:

```ruby
user.color_scheme    # :system, :light, :dark
user.light_theme     # :white, :selenized_light (default)
user.dark_theme      # :black, :selenized_dark (default)
```

The `theme_attributes` helper sets HTML attributes for theme switching. See `app/helpers/theme_helper.rb` and `app/javascript/controllers/theme_controller.js` for implementation.
