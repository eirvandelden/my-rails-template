# Wires the app onto the appkit engine (github.com/eirvandelden/appkit):
# session auth, PWA/push, and theme/preferences. Replaces what used to be
# hand-rolled here (and drifted across every app that copied it) with a
# shared, versioned dependency - `bundle update appkit` now carries fixes
# forward instead of a template edit.

say "Wiring up the appkit engine...", :blue

# The install generator's sessions migration branches on whether a `sessions`
# table already exists (align vs. create) - models.rb already generated one,
# but migrations haven't run yet, so migrate first or the generator would try
# to create a second, conflicting `sessions` table.
rails_command "db:migrate"
rails_command "generate appkit:install --force"
rails_command "db:migrate"

# Completely rewrite the User model: Appkit::Authenticatable supplies
# has_secure_password, the sessions/push_subscriptions associations, and
# deactivate!; Appkit::UserTheming supplies the color_scheme/light_theme/
# dark_theme enums (superseding the ones models.rb generated, which used
# different value names than the engine's mvpa themes expect).
remove_file "app/models/user.rb"
create_file "app/models/user.rb", <<~RUBY
  class User < ApplicationRecord
    include Appkit::Authenticatable
    include Appkit::UserTheming

    # Available locales
    AVAILABLE_LOCALES = %w[nl en it].freeze

    # Enums
    enum :role, { user: 0, admin: 1 }, default: :user

    # Validations
    validates :name, presence: false
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :role, presence: true
    validates :locale, presence: true, inclusion: { in: AVAILABLE_LOCALES }
    validates :timezone, presence: true, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }

    # Normalizations
    normalizes :name, with: -> name { name&.strip }
    normalizes :email, with: -> email { email.strip.downcase }

    # Callbacks
    after_create_commit -> { SendWelcomeEmailJob.perform_later(self) }

    # Set default locale
    after_initialize :set_defaults, if: :new_record?

    # Return timezone as ActiveSupport::TimeZone object
    def time_zone
      ActiveSupport::TimeZone[timezone]
    end

    private

    def set_defaults
      self.locale ||= "en"
      self.timezone ||= "UTC"
    end
  end
RUBY

# Completely rewrite the Session model: Appkit::SessionBehavior supplies
# has_secure_token, the last_active_at tracking, and Session.start!/#resume
# (superseding the ad hoc token generation models.rb generated).
remove_file "app/models/session.rb"
create_file "app/models/session.rb", <<~RUBY
  class Session < ApplicationRecord
    include Appkit::SessionBehavior

    belongs_to :user
  end
RUBY

# Mount the engine (session auth, first-run bootstrap, session transfer/QR
# handoff, preferences, PWA manifest/service worker, push subscriptions) in
# place of the routes models.rb's siblings used to define locally.
gsub_file "config/routes.rb",
  "  resource :preferences, only: [:edit, :update]\n  resource :session, only: [:new, :create, :destroy]\n",
  "  mount Appkit::Engine => \"/\"\n\n"

# Appkit::SessionsController/PreferencesController/etc. work via the host's
# own ApplicationController by constant lookup, not an explicit include - but
# Appkit::Authentication (before_action :require_authentication, helper_method
# :signed_in?) does need including, same as Authorization already is.
inject_into_class "app/controllers/application_controller.rb", "ApplicationController", <<~RUBY
  include Appkit::Authentication
RUBY

# Configuration - fill in the placeholders below for your app.
create_file "config/initializers/appkit.rb", <<~RUBY
  Appkit.configure do |config|
    # Display name used in the PWA manifest and login page.
    config.app_name = -> { Rails.application.class.module_parent_name }

    # Theme color used in the PWA manifest and browser chrome.
    config.brand_color = "#0000ff" # TODO: replace with your app's real brand color

    # This template's User model already uses :email/:locale, matching the
    # engine's defaults, so email_attribute/locale_attribute need no overrides.
    # config.email_attribute = :email
    # config.locale_attribute = :locale

    # Shows the timezone field on the preferences form (this template's User
    # model already has a :timezone column).
    config.timezone_attribute = :timezone

    # This template's role enum uses :admin (not the engine default
    # :administrator) - the FirstRun bootstrap flow needs to know that.
    config.first_run = ->(user_params) { User.create!(user_params.merge(role: :admin)) }
  end
RUBY

# appkit's own controllers are pinned under appkit/controllers/*, a separate
# importmap namespace from this app's local controllers/*, so
# eagerLoadControllersFrom does not pick them up - register explicitly.
# Skipping auto-submit would silently break the session-transfer (magic-link)
# flow: the page renders but never submits.
append_to_file "app/javascript/controllers/index.js", <<~JS

  // appkit's own controllers are pinned under appkit/controllers/*, a separate
  // importmap namespace from our local controllers/*, so eagerLoadControllersFrom
  // above won't find them - register the ones we use explicitly.
  import PushController from "appkit/controllers/push_controller"
  application.register("push", PushController)

  import ThemeController from "appkit/controllers/theme_controller"
  application.register("theme", ThemeController)

  import AutoSubmitController from "appkit/controllers/auto_submit_controller"
  application.register("auto-submit", AutoSubmitController)
JS

inject_into_file "app/javascript/application.js", after: "import \"controllers\"\n" do
  "import \"appkit/pwa\"\n"
end

# Brand-accent token appkit's own login page styling reads - pick a real
# accent from mvpa's palette (--color-red/green/yellow/blue/magenta/cyan/
# orange/violet, see mvpa/4_theme/0_colors.css) instead of the placeholder.
empty_directory "app/assets/stylesheets/themes"
create_file "app/assets/stylesheets/themes/brand.css", <<~CSS
  /* This app's brand accent, referenced by appkit's login page styling. */
  :root {
    --color-accent: var(--color-blue); /* TODO: pick your app's real accent */
  }
CSS

# Forgetting the appkit/login.css import is an easy mistake to make (it
# happened in every app that adopted this engine before the template caught
# up) - the login page renders completely unstyled without it.
gsub_file "app/assets/stylesheets/application.css", '@import url("mvpa/mvpa.css");', <<~CSS.strip
  @import url("mvpa/mvpa.css");

  /* This app's brand accent, referenced by appkit's login page styling */
  @import url("themes/brand.css");

  /* appkit's login layout styling */
  @import url("appkit/login.css");
CSS

# Layout wiring: theme attributes + appkit's own PWA meta tags/flash partial,
# replacing the home-grown ThemeHelper/flash markup theme_system.rb/home.rb
# used to render. Full rewrites (not surgical patches) to keep this robust
# regardless of exact prior indentation.
remove_file "app/views/layouts/application.html.erb"
create_file "app/views/layouts/application.html.erb", <<~ERB
  <!DOCTYPE html>
  <html lang="<%= I18n.locale %>" data-controller="theme" <%= tag.attributes(theme_attributes) %>>
    <head>
      <title><%= content_for(:title) || Rails.application.class.module_parent_name %></title>
      <meta name="viewport" content="width=device-width,initial-scale=1">
      <meta name="view-transition" content="same-origin">
      <meta name="color-scheme" content="light dark">
      <%= csrf_meta_tags %>
      <%= csp_meta_tag %>
      <%= yield :head %>

      <%= render "appkit/shared/pwa_meta" %>
      <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
      <%= javascript_importmap_tags %>
    </head>

    <body>
      <header>
        <nav>
          <%= link_to_unless_current t("nav.home"), root_path %>
          <% if signed_in? %>
            <%= link_to_unless_current t("nav.preferences"), edit_preferences_path %>
            <% if Current.user.admin? %>
              <%= link_to_unless_current t("nav.admin"), admin_root_path %>
            <% end %>
            <%= button_to t("sessions.sign_out"), session_path, method: :delete %>
          <% else %>
            <%= link_to_unless_current t("sessions.sign_in"), new_session_path %>
          <% end %>
        </nav>
      </header>

      <main>
        <%= render "appkit/shared/flashes" %>

        <%= yield %>
      </main>

      <footer>
        <p><%= t("footer.copyright", year: Date.current.year, app_name: Rails.application.class.module_parent_name) %></p>
      </footer>
    </body>
  </html>
ERB

remove_file "app/views/home/index.html.erb"
create_file "app/views/home/index.html.erb", <<~ERB
  <h1><%= t(".welcome") %></h1>

  <% if signed_in? %>
    <p><%= t(".signed_in_as", email: Current.user.email, role: Current.user.role) %></p>

    <% if Current.user.admin? %>
      <p><%= link_to t(".admin_panel"), admin_root_path %></p>
    <% end %>

    <%= button_to t("sessions.sign_out"), session_path, method: :delete %>
  <% else %>
    <p><%= link_to t("sessions.sign_in"), new_session_path %></p>
  <% end %>
ERB

remove_file "app/views/layouts/admin.html.erb"
create_file "app/views/layouts/admin.html.erb", <<~ERB
  <!DOCTYPE html>
  <html lang="<%= I18n.locale %>" data-controller="theme" <%= tag.attributes(theme_attributes) %>>
    <head>
      <title><%= t("admin.title") %> - <%= Rails.application.class.module_parent_name %></title>
      <meta name="viewport" content="width=device-width,initial-scale=1">
      <meta name="view-transition" content="same-origin">
      <meta name="color-scheme" content="light dark">
      <meta name="turbo-cache-control" content="no-cache">
      <%= csrf_meta_tags %>
      <%= csp_meta_tag %>

      <%= render "appkit/shared/pwa_meta" %>
      <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
      <%= javascript_importmap_tags %>
    </head>

    <body>
      <header>
        <nav>
          <%= link_to t("admin.nav.dashboard"), admin_root_path %>
          <%= link_to t("admin.nav.users"), admin_users_path %>
          <%= link_to t("admin.nav.faultline"), faultline.root_path %>
          <%# link_to t("admin.nav.mission_control"), mission_control_jobs.root_path %>
          <%= link_to t("admin.nav.back_to_site"), root_path %>
        </nav>
      </header>

      <main>
        <%= render "appkit/shared/flashes" %>

        <%= yield %>
      </main>
    </body>
  </html>
ERB

# Placeholder lettermark icon - replace public/icon.svg with your own artwork
# before shipping. Rasterizes the sizes appkit's PWA manifest advertises by
# default (see Appkit::Configuration::DEFAULT_ICONS).
create_file "public/icon.svg", <<~SVG, force: true
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" role="img" aria-label="App">
    <rect width="512" height="512" rx="96" fill="#0000ff"/>
    <text x="256" y="336" font-family="system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif"
          font-size="288" font-weight="700" fill="#ffffff" text-anchor="middle">A</text>
  </svg>
SVG

if system("which rsvg-convert > /dev/null 2>&1")
  run "rsvg-convert -w 192 -h 192 public/icon.svg -o public/icon-192.png"
  run "rsvg-convert -w 512 -h 512 public/icon.svg -o public/icon-512.png"
  run "rsvg-convert -w 512 -h 512 public/icon.svg -o public/icon-mask-512.png"
  run "rsvg-convert -w 180 -h 180 public/icon.svg -o public/apple-touch-icon.png"
  say "  ✓ Generated PNG icons from public/icon.svg via rsvg-convert", :green
else
  say "  rsvg-convert not found - install it (brew install librsvg) and run:", :yellow
  say "    rsvg-convert -w 192 -h 192 public/icon.svg -o public/icon-192.png", :white
  say "    rsvg-convert -w 512 -h 512 public/icon.svg -o public/icon-512.png", :white
  say "    rsvg-convert -w 512 -h 512 public/icon.svg -o public/icon-mask-512.png", :white
  say "    rsvg-convert -w 180 -h 180 public/icon.svg -o public/apple-touch-icon.png", :white
end

say "✓ appkit engine wired up", :green
say "  - Session auth, first-run bootstrap, session transfer/QR handoff: mounted", :white
say "  - Theme/preferences: mounted, app/assets/stylesheets/themes/brand.css holds the accent", :white
say "  - PWA/push: manifest + service worker mounted, public/icon.svg is a placeholder", :white
say "  Before shipping:", :yellow
say "    1. Edit config/initializers/appkit.rb: app_name, brand_color, first_run role", :white
say "    2. Replace public/icon.svg with real artwork, or re-run the rsvg-convert commands above", :white
say "    3. Generate VAPID keys for web push: bin/rails appkit:vapid_keys", :white
say "       then paste the printed credentials.yml.enc snippet via bin/rails credentials:edit", :white
say "    4. Engine fixes now arrive via `bundle update appkit`, no template edit needed", :white
