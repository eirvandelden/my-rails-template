# User and Session models

# Generate User model with role enum and preferences
generate :model, "User",
  "name:string",
  "email:string:uniq",
  "password_digest:string",
  "active:boolean",
  "role:integer",
  "last_login_at:datetime",
  "locale:string",
  "timezone:string",
  "color_scheme:integer",
  "light_theme:integer",
  "dark_theme:integer"

# Generate Session model
generate :model, "Session", "user:references", "token:string:uniq", "ip_address:string", "user_agent:string"

# Completely rewrite User model
remove_file "app/models/user.rb"
create_file "app/models/user.rb", <<~RUBY
  class User < ApplicationRecord
    has_secure_password
    has_many :sessions, dependent: :destroy

    # Available locales
    AVAILABLE_LOCALES = %w[nl en it].freeze

    # Enums
    enum :role, { user: 0, admin: 1 }, default: :user
    enum :color_scheme, { system: 0, light: 1, dark: 2 }, default: :system
    enum :light_theme, { white: 0, selenized_light: 1 }, default: :selenized_light
    enum :dark_theme, { black: 0, selenized_dark: 1 }, default: :selenized_dark

    # Validations
    validates :name, presence: false
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :role, presence: true
    validates :locale, presence: true, inclusion: { in: AVAILABLE_LOCALES }
    validates :timezone, presence: true, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }
    validates :color_scheme, presence: true
    validates :light_theme, presence: true
    validates :dark_theme, presence: true

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

# Completely rewrite Session model
remove_file "app/models/session.rb"
create_file "app/models/session.rb", <<~RUBY
  class Session < ApplicationRecord
    belongs_to :user

    before_create do
      self.token = SecureRandom.base58(32)
    end
  end
RUBY

# Add migration to set default values
inject_into_file Dir["db/migrate/*_create_users.rb"].first,
  after: "create_table :users do |t|\n" do
  <<-RUBY
      t.string :email, null: false
      t.string :password_digest, null: false
      t.boolean :active, default: true, null: false
      t.integer :role, default: 0, null: false
      t.string :locale, default: "en", null: false
      t.string :timezone, default: "UTC", null: false
      t.integer :color_scheme, default: 0, null: false
      t.integer :light_theme, default: 1, null: false
      t.integer :dark_theme, default: 1, null: false
  RUBY
end

# Remove the duplicate column definitions that Rails generates
gsub_file Dir["db/migrate/*_create_users.rb"].first, /^      t\.string :email$/, ""
gsub_file Dir["db/migrate/*_create_users.rb"].first, /^      t\.string :password_digest$/, ""
gsub_file Dir["db/migrate/*_create_users.rb"].first, /^      t\.boolean :active$/, ""
gsub_file Dir["db/migrate/*_create_users.rb"].first, /^      t\.integer :role$/, ""
gsub_file Dir["db/migrate/*_create_users.rb"].first, /^      t\.string :locale$/, ""
gsub_file Dir["db/migrate/*_create_users.rb"].first, /^      t\.string :timezone$/, ""
gsub_file Dir["db/migrate/*_create_users.rb"].first, /^      t\.integer :color_scheme$/, ""
gsub_file Dir["db/migrate/*_create_users.rb"].first, /^      t\.integer :light_theme$/, ""
gsub_file Dir["db/migrate/*_create_users.rb"].first, /^      t\.integer :dark_theme$/, ""
