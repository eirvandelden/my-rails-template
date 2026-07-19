# I18n configuration and locale files

say "Setting up i18n...", :blue

# Configure available locales. Rails 8.1's default config/application.rb no
# longer ships the commented-out `config.i18n.default_locale = :de` line this
# used to anchor on, so without this, config.i18n.available_locales is never
# set and Rails falls back to every locale file on the load path - including
# the 100+ rails-i18n ships - which breaks locale-restricted tests/UI.
gsub_file "config/application.rb", /(config\.load_defaults \d+\.\d+\n)/, <<~RUBY
  \\1
      config.i18n.available_locales = %i[en nl it]
      config.i18n.default_locale = :en
      config.i18n.fallbacks = true
RUBY

# English locale
remove_file "config/locales/en.yml"
create_file "config/locales/en.yml", <<~YAML
  en:
    locales:
      en: "English"
      nl: "Nederlands"
      it: "Italiano"

    nav:
      home: "Home"
      preferences: "Preferences"
      admin: "Admin"

    sessions:
      sign_in: "Sign in"
      sign_out: "Sign out"

    home:
      index:
        welcome: "Welcome"
        signed_in_as: "You are signed in as %{email} (%{role})"
        admin_panel: "Admin Panel"

    admin:
      title: "Admin"
      nav:
        dashboard: "Dashboard"
        users: "Users"
        faultline: "Faultline"
        back_to_site: "Back to Site"
      dashboard:
        index:
          title: "Dashboard"
          summary: "Summary"
          total_users: "Total Users"
          admin_users: "Admin Users"
          recent_logins: "Recent Logins"
          name: "Name"
          email: "Email"
          role: "Role"
          last_login_at: "Last Login"
          actions: "Actions"
          no_name: "-"
          never: "Never"
          view: "View"
          edit: "Edit"
      users:
        index:
          title: "User Management"
          new_user: "New User"
          name: "Name"
          email: "Email"
          role: "Role"
          last_login_at: "Last Login"
          created_at: "Created"
          actions: "Actions"
          no_name: "-"
          never: "Never"
          view: "View"
          edit: "Edit"
          delete: "Delete"
          confirm_delete: "Are you sure you want to delete this user?"
        show:
          title: "User Details"
          name: "Name"
          no_name: "-"
          email: "Email"
          role: "Role"
          last_login_at: "Last Login"
          never: "Never"
          created_at: "Created"
          active_sessions: "Active Sessions"
          edit: "Edit"
          back: "Back"
        new:
          title: "New User"
          submit: "Create User"
        form:
          name: "Name"
          email: "Email"
          role: "Role"
          password: "Password"
          password_confirmation: "Confirm Password"
          cancel: "Cancel"
        create:
          success: "User created successfully"
        edit:
          title: "Edit User"
          submit: "Update User"
        update:
          success: "User updated successfully"
        destroy:
          success: "User deleted successfully"
          cannot_delete_self: "You cannot delete yourself"

    footer:
      copyright: "© %{year} %{app_name}"
YAML

# Dutch locale
create_file "config/locales/nl.yml", <<~YAML
  nl:
    locales:
      en: "English"
      nl: "Nederlands"
      it: "Italiano"

    nav:
      home: "Home"
      preferences: "Voorkeuren"
      admin: "Beheer"

    sessions:
      sign_in: "Inloggen"
      sign_out: "Uitloggen"

    home:
      index:
        welcome: "Welkom"
        signed_in_as: "Je bent ingelogd als %{email} (%{role})"
        admin_panel: "Beheerpaneel"

    admin:
      title: "Beheer"
      nav:
        dashboard: "Dashboard"
        users: "Gebruikers"
        faultline: "Faultline"
        back_to_site: "Terug naar site"
      dashboard:
        index:
          title: "Dashboard"
          summary: "Overzicht"
          total_users: "Totaal gebruikers"
          admin_users: "Admin-gebruikers"
          recent_logins: "Recente logins"
          name: "Naam"
          email: "E-mail"
          role: "Rol"
          last_login_at: "Laatste login"
          actions: "Acties"
          no_name: "-"
          never: "Nooit"
          view: "Bekijken"
          edit: "Bewerken"
      users:
        index:
          title: "Gebruikersbeheer"
          new_user: "Nieuwe gebruiker"
          name: "Naam"
          email: "E-mail"
          role: "Rol"
          last_login_at: "Laatste login"
          created_at: "Aangemaakt"
          actions: "Acties"
          no_name: "-"
          never: "Nooit"
          view: "Bekijken"
          edit: "Bewerken"
          delete: "Verwijderen"
          confirm_delete: "Weet je zeker dat je deze gebruiker wilt verwijderen?"
        show:
          title: "Gebruikersdetails"
          name: "Naam"
          no_name: "-"
          email: "E-mail"
          role: "Rol"
          last_login_at: "Laatste login"
          never: "Nooit"
          created_at: "Aangemaakt"
          active_sessions: "Actieve sessies"
          edit: "Bewerken"
          back: "Terug"
        new:
          title: "Nieuwe gebruiker"
          submit: "Gebruiker aanmaken"
        form:
          name: "Naam"
          email: "E-mail"
          role: "Rol"
          password: "Wachtwoord"
          password_confirmation: "Bevestig wachtwoord"
          cancel: "Annuleren"
        create:
          success: "Gebruiker succesvol aangemaakt"
        edit:
          title: "Gebruiker bewerken"
          submit: "Gebruiker bijwerken"
        update:
          success: "Gebruiker succesvol bijgewerkt"
        destroy:
          success: "Gebruiker succesvol verwijderd"
          cannot_delete_self: "Je kunt jezelf niet verwijderen"

    footer:
      copyright: "© %{year} %{app_name}"
YAML

# Italian locale
create_file "config/locales/it.yml", <<~YAML
  it:
    locales:
      en: "English"
      nl: "Nederlands"
      it: "Italiano"

    nav:
      home: "Home"
      preferences: "Preferenze"
      admin: "Admin"

    sessions:
      sign_in: "Accedi"
      sign_out: "Esci"

    home:
      index:
        welcome: "Benvenuto"
        signed_in_as: "Hai effettuato l'accesso come %{email} (%{role})"
        admin_panel: "Pannello Admin"

    admin:
      title: "Admin"
      nav:
        dashboard: "Dashboard"
        users: "Utenti"
        faultline: "Faultline"
        back_to_site: "Torna al sito"
      dashboard:
        index:
          title: "Dashboard"
          summary: "Riepilogo"
          total_users: "Utenti totali"
          admin_users: "Utenti admin"
          recent_logins: "Accessi recenti"
          name: "Nome"
          email: "Email"
          role: "Ruolo"
          last_login_at: "Ultimo accesso"
          actions: "Azioni"
          no_name: "-"
          never: "Mai"
          view: "Visualizza"
          edit: "Modifica"
      users:
        index:
          title: "Gestione utenti"
          new_user: "Nuovo utente"
          name: "Nome"
          email: "Email"
          role: "Ruolo"
          last_login_at: "Ultimo accesso"
          created_at: "Creato"
          actions: "Azioni"
          no_name: "-"
          never: "Mai"
          view: "Visualizza"
          edit: "Modifica"
          delete: "Elimina"
          confirm_delete: "Sei sicuro di voler eliminare questo utente?"
        show:
          title: "Dettagli utente"
          name: "Nome"
          no_name: "-"
          email: "Email"
          role: "Ruolo"
          last_login_at: "Ultimo accesso"
          never: "Mai"
          created_at: "Creato"
          active_sessions: "Sessioni attive"
          edit: "Modifica"
          back: "Indietro"
        new:
          title: "Nuovo utente"
          submit: "Crea utente"
        form:
          name: "Nome"
          email: "Email"
          role: "Ruolo"
          password: "Password"
          password_confirmation: "Conferma password"
          cancel: "Annulla"
        create:
          success: "Utente creato con successo"
        edit:
          title: "Modifica utente"
          submit: "Aggiorna utente"
        update:
          success: "Utente aggiornato"
        destroy:
          success: "Utente eliminato"
          cannot_delete_self: "Non puoi eliminare te stesso"

    footer:
      copyright: "© %{year} %{app_name}"
YAML

# i18n-tasks configuration
create_file "config/i18n-tasks.yml", <<~YAML
  base_locale: en

  locales: [en, nl, it]

  data:
    read:
      - config/locales/%{locale}.yml

    write:
      - ['{.:}', 'config/locales/%{locale}.yml']

  search:
    paths:
      - app/

    relative_roots:
      - app/controllers
      - app/helpers
      - app/mailers
      - app/presenters
      - app/views

    exclude:
      - app/assets/images
      - app/assets/fonts
      - app/assets/videos
      - app/assets/builds

    # Extract t() and I18n.t() calls
    pattern: "\\\\bt[( ]\\\\s*['\\"]:?([\\\\w.]+)"

  ignore_missing:
    - 'errors.messages.*'
    - 'activerecord.*'
    - 'date.*'
    - 'time.*'
    - 'number.*'
    - 'helpers.*'

  ignore_unused:
    - 'activerecord.*'
    - 'errors.*'
    - 'date.*'
    - 'time.*'
    - 'number.*'
    - 'helpers.*'
YAML

# Create i18n test helper for Minitest
create_file "test/helpers/i18n_test_helper.rb", <<~RUBY
  module I18nTestHelper
    # Test that all translations are present for a given locale
    def assert_translations_present(locale, keys)
      I18n.with_locale(locale) do
        keys.each do |key|
          translation = I18n.t(key, raise: true)
          assert translation.present?, "Missing translation for \#{locale}.\#{key}"
        rescue I18n::MissingTranslationData
          flunk "Missing translation for \#{locale}.\#{key}"
        end
      end
    end

    # Test that no translations are missing across all locales
    def assert_no_missing_translations
      require "i18n/tasks"
      i18n = I18n::Tasks::BaseTask.new
      missing = i18n.missing_keys

      assert missing.empty?, "Missing translations:\\n\#{missing.inspect}"
    end

    # Test that no translations are unused
    def assert_no_unused_translations
      require "i18n/tasks"
      i18n = I18n::Tasks::BaseTask.new
      unused = i18n.unused_keys

      assert unused.empty?, "Unused translations:\\n\#{unused.inspect}"
    end
  end
RUBY

# Create i18n integration test
create_file "test/integration/i18n_test.rb", <<~RUBY
  require "test_helper"
  require "helpers/i18n_test_helper"

  class I18nTest < ActionDispatch::IntegrationTest
    include I18nTestHelper

    test "all locales have required navigation keys" do
      nav_keys = %w[nav.home nav.preferences nav.admin]

      I18n.available_locales.each do |locale|
        assert_translations_present(locale, nav_keys)
      end
    end

    test "all locales have required session keys" do
      session_keys = %w[
        sessions.sign_in
        sessions.sign_out
      ]

      I18n.available_locales.each do |locale|
        assert_translations_present(locale, session_keys)
      end
    end

    test "locale can be changed" do
      I18n.available_locales.each do |locale|
        I18n.with_locale(locale) do
          assert_equal locale, I18n.locale
          # Verify a basic translation works
          assert I18n.t("nav.home").present?
        end
      end
    end
  end
RUBY

say "✓ I18n configured with en, nl, it locales", :green
say "✓ i18n-tasks configuration created", :green
say "✓ I18n test helpers created", :green
