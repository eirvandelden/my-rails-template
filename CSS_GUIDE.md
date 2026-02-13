# CSS System Guide

The Paris template uses **[MVPA.css](https://github.com/eirvandelden/MVPA.css)** as its CSS framework.

## About MVPA.css

MVPA.css is a classless CSS framework featuring:
- Semantic HTML styling (minimal classes needed)
- OKLCH Selenized color system (4 themes)
- 37signals spacing methodology (1ch × 1rem base units)
- Rails-specific components (flash messages, errors, forms)
- Theme switching with user preferences
- Mobile-first responsive design

## Framework Integration

### Gem Installation

MVPA.css is installed as a gem from GitHub:

```ruby
# Gemfile
gem "mvpa-css", github: "eirvandelden/mvpa.css"
```

The gem provides its CSS assets via the Rails asset pipeline (Propshaft). No manual file copying needed!

### In Generated Apps

Generated apps include MVPA.css via `app/assets/stylesheets/application.css`:

```css
/* app/assets/stylesheets/application.css */
@import "mvpa/mvpa";
```

This single import loads all MVPA.css components in the correct order:
- `0_settings/` - OKLCH Selenized colors, CSS variables
- `1_base/` - Reset, typography, tables, forms, details
- `2_layout/` - Header, main, footer
- `3_components/` - Flash, errors, buttons, progress, etc.
- `4_themes/` - Theme switching logic

## Features

- **Classless approach** - Semantic HTML is styled by default
- **OKLCH colors** - Perceptually uniform Selenized color scheme
- **4 themes** - White, Selenized Light (default), Black, Selenized Dark (default)
- **User preferences** - Theme switching based on user model
- **37signals spacing** - 1ch × 1rem base unit system
- **Responsive** - Mobile-first design
- **Dark mode** - Respects system preference + user choice

## Updating MVPA.css

### For App Developers

Update to the latest MVPA.css version:

```bash
bundle update mvpa-css
```

This pulls the latest changes from the MVPA.css GitHub repository.

## Local Customizations

Add app-specific CSS in `app/assets/stylesheets/application.css` after the MVPA.css import:

```css
/* app/assets/stylesheets/application.css */
@import "mvpa/mvpa";

/* Your local customizations */
:root {
  --inline-space: 1.5ch;  /* Override MVPA.css spacing */
  --my-custom-color: oklch(60% 0.15 270);
}

.my-custom-component {
  padding: var(--block-space);
  background: var(--my-custom-color);
}
```

**Best practice:** Use CSS custom properties to override MVPA.css defaults rather than redefining styles.

### Separate Local CSS Files

For larger customizations, create separate CSS files:

```css
/* app/assets/stylesheets/application.css */
@import "mvpa/mvpa";
@import "local/custom";
```

```css
/* app/assets/stylesheets/local/custom.css */
:root {
  /* Your overrides */
}
```

## Theme System

### User Model Preferences

Users have these preference fields:

```ruby
user.locale          # "nl", "en", "it"
user.color_scheme    # :system, :light, :dark
user.light_theme     # :white, :selenized_light (default)
user.dark_theme      # :black, :selenized_dark (default)
```

### Theme Application Priority

1. User's explicit color_scheme choice (system/light/dark)
2. User's theme choice (white/selenized_light for light, black/selenized_dark for dark)
3. System preference (prefers-color-scheme)
4. Default: Selenized Light/Dark

### HTML Attributes

The theme system sets these attributes on `<html>`:

```html
<!-- User prefers system setting, currently light mode -->
<html data-color-scheme="system" light-theme="selenized_light">

<!-- User explicitly chose dark mode with black theme -->
<html data-color-scheme="dark" dark-theme="black">

<!-- User explicitly chose light mode with white theme -->
<html data-color-scheme="light" light-theme="white">
```

## Classless Approach

### Forms

Forms are completely classless:

```erb
<form>
  <fieldset>
    <legend>Account Settings</legend>

    <label for="email">Email</label>
    <input type="email" id="email" name="user[email]">

    <label for="locale">Language</label>
    <select id="locale" name="user[locale]">
      <option value="en">English</option>
      <option value="nl">Nederlands</option>
      <option value="it">Italiano</option>
    </select>

    <button type="submit">Save</button>
  </fieldset>
</form>
```

No classes needed! The CSS styles semantic HTML elements directly.

### Button Variants

Only use classes for variants:

```erb
<!-- Default button (no class) -->
<button>Save</button>

<!-- Variant buttons (minimal classes) -->
<button class="button-success">Confirm</button>
<button class="button-danger">Delete</button>
<button class="button-warning">Warning</button>
<button class="button-secondary">Cancel</button>
```

### Flash Messages

Use semantic HTML with ARIA roles:

```erb
<!-- Success message -->
<div role="status" class="notice">
  <%= flash[:notice] %>
</div>

<!-- Error message -->
<div role="alert" class="alert">
  <%= flash[:alert] %>
</div>
```

## Color System

### OKLCH Colors

All colors use OKLCH for perceptual uniformity:

```css
--lch-red: 50% 0.19 20;
--color-red: oklch(var(--lch-red));
```

Benefits:
- Consistent perceived brightness across hues
- Smooth color transitions
- Better for accessibility

### Selenized Colors

Four complete themes based on Selenized:

1. **White** - Pure white background (high contrast)
2. **Selenized Light** - Warm, cream background (default light)
3. **Black** - Pure black background (high contrast)
4. **Selenized Dark** - Muted dark background (default dark)

### Semantic Colors

CSS provides semantic color mappings:

```css
--color-primary: var(--color-blue);
--color-success: var(--color-green);
--color-danger: var(--color-red);
--color-warning: var(--color-yellow);
--color-info: var(--color-cyan);
```

## Spacing System

### 37signals Base Units

```css
/* Inline spacing (horizontal) */
--inline-space: 1ch;          /* ~8-10px */
--inline-space-half: 0.5ch;
--inline-space-double: 2ch;

/* Block spacing (vertical) */
--block-space: 1rem;          /* 16px */
--block-space-half: 0.5rem;
--block-space-double: 2rem;
```

### Logical Properties

The CSS uses logical properties for internationalization:

```css
/* Instead of margin-left/right */
margin-inline: var(--inline-space);

/* Instead of margin-top/bottom */
margin-block: var(--block-space);

/* Instead of width */
inline-size: 100%;

/* Instead of height */
block-size: auto;
```

This automatically flips for RTL languages.

## Responsive Design

### Mobile-First

Base font size adjusts for mobile:

```css
html {
  font-size: 100%; /* 16px */
}

@media (max-width: 768px) {
  html {
    font-size: 87.5%; /* 14px */
  }
}
```

### Form Inputs

All inputs use 16px minimum to prevent iOS zoom:

```css
input {
  font-size: 1rem; /* Always 16px minimum */
}
```

## Usage in Views

### Layout with Theme Support

```erb
<!DOCTYPE html>
<html<%= tag.attributes(theme_attributes) if defined?(theme_attributes) %>>
  <head>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```

### Preferences Form

```erb
<%= form_with model: @user do |form| %>
  <fieldset>
    <legend>Appearance</legend>

    <label for="user_color_scheme">Color Scheme</label>
    <%= form.select :color_scheme,
      User.color_schemes.keys.map { |k| [k.titleize, k] } %>

    <label for="user_light_theme">Light Theme</label>
    <%= form.select :light_theme,
      User.light_themes.keys.map { |k| [k.titleize, k] } %>

    <label for="user_dark_theme">Dark Theme</label>
    <%= form.select :dark_theme,
      User.dark_themes.keys.map { |k| [k.titleize, k] } %>
  </fieldset>

  <button type="submit">Save Preferences</button>
<% end %>
```

## Browser Support

- Modern browsers with OKLCH support (Chrome 111+, Safari 15.4+, Firefox 113+)
- Fallback colors automatically used in older browsers
- All responsive features work in modern browsers

## Performance

- No CSS-in-JS overhead
- Small file size (~10KB total)
- Minimal specificity conflicts
- No unused utility classes
- Served via Rails asset pipeline

## Accessibility

- Proper focus indicators
- Keyboard navigation support
- ARIA roles for flash messages
- Sufficient color contrast
- Logical properties for RTL support
- Semantic HTML structure

## Contributing to MVPA.css

If you improve MVPA.css while working on apps:
1. Clone MVPA.css repo separately: `git clone https://github.com/eirvandelden/mvpa.css`
2. Make improvements and push to MVPA.css repo
3. Update apps to use latest: `bundle update mvpa-css`
4. All future apps benefit from improvements
