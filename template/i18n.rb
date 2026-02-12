# I18n configuration and locale files

say "Setting up i18n...", :blue

# Configure available locales
gsub_file "config/application.rb", /# config\.i18n\.default_locale = :de/, <<~RUBY.strip
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

    color_schemes:
      system: "System"
      light: "Light"
      dark: "Dark"

    themes:
      white: "White"
      selenized_light: "Selenized Light"
      black: "Black"
      selenized_dark: "Selenized Dark"

    nav:
      home: "Home"
      preferences: "Preferences"
      admin: "Admin"

    sessions:
      sign_in: "Sign in"
      sign_out: "Sign out"
      new:
        title: "Sign in"
        email: "Email"
        password: "Password"
        submit: "Sign in"
      create:
        success: "Signed in successfully"
        failure: "Invalid email or password"
      destroy:
        success: "Signed out successfully"

    home:
      index:
        welcome: "Welcome"
        signed_in_as: "You are signed in as %{email} (%{role})"
        admin_panel: "Admin Panel"

    preferences:
      edit:
        title: "Preferences"
        language: "Language"
        locale: "Locale"
        timezone: "Timezone"
        appearance: "Appearance"
        color_scheme: "Color Scheme"
        color_scheme_hint: "System follows your device settings"
        light_theme: "Light Theme"
        dark_theme: "Dark Theme"
        submit: "Save Preferences"
      update:
        success: "Preferences updated successfully"

    admin:
      title: "Admin"
      nav:
        dashboard: "Dashboard"
        users: "Users"
        back_to_site: "Back to Site"
      users:
        index:
          title: "User Management"
          email: "Email"
          role: "Role"
          created_at: "Created"
          actions: "Actions"
          view: "View"
          edit: "Edit"
          delete: "Delete"
          confirm_delete: "Are you sure you want to delete this user?"
        show:
          title: "User Details"
          email: "Email"
          role: "Role"
          created_at: "Created"
          active_sessions: "Active Sessions"
          edit: "Edit"
          back: "Back"
        edit:
          title: "Edit User"
          email: "Email"
          role: "Role"
          submit: "Update User"
          cancel: "Cancel"
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

    color_schemes:
      system: "Systeem"
      light: "Licht"
      dark: "Donker"

    themes:
      white: "Wit"
      selenized_light: "Selenized Licht"
      black: "Zwart"
      selenized_dark: "Selenized Donker"

    nav:
      home: "Home"
      preferences: "Voorkeuren"
      admin: "Beheer"

    sessions:
      sign_in: "Inloggen"
      sign_out: "Uitloggen"
      new:
        title: "Inloggen"
        email: "E-mail"
        password: "Wachtwoord"
        submit: "Inloggen"
      create:
        success: "Succesvol ingelogd"
        failure: "Ongeldige e-mail of wachtwoord"
      destroy:
        success: "Succesvol uitgelogd"

    home:
      index:
        welcome: "Welkom"
        signed_in_as: "Je bent ingelogd als %{email} (%{role})"
        admin_panel: "Beheerpaneel"

    preferences:
      edit:
        title: "Voorkeuren"
        language: "Taal"
        locale: "Taal"
        timezone: "Tijdzone"
        appearance: "Weergave"
        color_scheme: "Kleurenschema"
        color_scheme_hint: "Systeem volgt je apparaatinstellingen"
        light_theme: "Licht thema"
        dark_theme: "Donker thema"
        submit: "Voorkeuren opslaan"
      update:
        success: "Voorkeuren succesvol bijgewerkt"

    admin:
      title: "Beheer"
      nav:
        dashboard: "Dashboard"
        users: "Gebruikers"
        back_to_site: "Terug naar site"
      users:
        index:
          title: "Gebruikersbeheer"
          email: "E-mail"
          role: "Rol"
          created_at: "Aangemaakt"
          actions: "Acties"
          view: "Bekijken"
          edit: "Bewerken"
          delete: "Verwijderen"
          confirm_delete: "Weet je zeker dat je deze gebruiker wilt verwijderen?"
        show:
          title: "Gebruikersdetails"
          email: "E-mail"
          role: "Rol"
          created_at: "Aangemaakt"
          active_sessions: "Actieve sessies"
          edit: "Bewerken"
          back: "Terug"
        edit:
          title: "Gebruiker bewerken"
          email: "E-mail"
          role: "Rol"
          submit: "Gebruiker bijwerken"
          cancel: "Annuleren"
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

    color_schemes:
      system: "Sistema"
      light: "Chiaro"
      dark: "Scuro"

    themes:
      white: "Bianco"
      selenized_light: "Selenized Chiaro"
      black: "Nero"
      selenized_dark: "Selenized Scuro"

    nav:
      home: "Home"
      preferences: "Preferenze"
      admin: "Admin"

    sessions:
      sign_in: "Accedi"
      sign_out: "Esci"
      new:
        title: "Accedi"
        email: "Email"
        password: "Password"
        submit: "Accedi"
      create:
        success: "Accesso effettuato"
        failure: "Email o password non validi"
      destroy:
        success: "Disconnessione effettuata"

    home:
      index:
        welcome: "Benvenuto"
        signed_in_as: "Hai effettuato l'accesso come %{email} (%{role})"
        admin_panel: "Pannello Admin"

    preferences:
      edit:
        title: "Preferenze"
        language: "Lingua"
        locale: "Lingua"
        timezone: "Fuso orario"
        appearance: "Aspetto"
        color_scheme: "Schema colori"
        color_scheme_hint: "Sistema segue le impostazioni del dispositivo"
        light_theme: "Tema chiaro"
        dark_theme: "Tema scuro"
        submit: "Salva preferenze"
      update:
        success: "Preferenze aggiornate"

    admin:
      title: "Admin"
      nav:
        dashboard: "Dashboard"
        users: "Utenti"
        back_to_site: "Torna al sito"
      users:
        index:
          title: "Gestione utenti"
          email: "Email"
          role: "Ruolo"
          created_at: "Creato"
          actions: "Azioni"
          view: "Visualizza"
          edit: "Modifica"
          delete: "Elimina"
          confirm_delete: "Sei sicuro di voler eliminare questo utente?"
        show:
          title: "Dettagli utente"
          email: "Email"
          role: "Ruolo"
          created_at: "Creato"
          active_sessions: "Sessioni attive"
          edit: "Modifica"
          back: "Indietro"
        edit:
          title: "Modifica utente"
          email: "Email"
          role: "Ruolo"
          submit: "Aggiorna utente"
          cancel: "Annulla"
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
        sessions.new.title
        sessions.new.email
        sessions.new.password
        sessions.new.submit
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
