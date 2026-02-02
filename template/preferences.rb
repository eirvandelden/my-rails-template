# User preferences controller and views

# Create Preferences controller
create_file "app/controllers/preferences_controller.rb", <<~RUBY
  class PreferencesController < ApplicationController
    def edit
      @user = Current.user
    end

    def update
      @user = Current.user

      if @user.update(preference_params)
        redirect_to edit_preferences_path, notice: "Preferences updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def preference_params
      params.require(:user).permit(:locale, :color_scheme, :light_theme, :dark_theme)
    end
  end
RUBY

# Create preferences view
create_file "app/views/preferences/edit.html.erb", <<~ERB
  <h1>Preferences</h1>

  <%= form_with model: @user, url: preferences_path do |form| %>
    <% if @user.errors.any? %>
      <aside role="alert">
        <h2><%= pluralize(@user.errors.count, "error") %> prohibited saving:</h2>
        <ul>
          <% @user.errors.each do |error| %>
            <li><%= error.full_message %></li>
          <% end %>
        </ul>
      </aside>
    <% end %>

    <fieldset>
      <legend>Language</legend>

      <label for="user_locale">Locale</label>
      <%= form.select :locale, User::AVAILABLE_LOCALES.map { |l| [l.upcase, l] } %>
    </fieldset>

    <fieldset>
      <legend>Appearance</legend>

      <label for="user_color_scheme">Color Scheme</label>
      <%= form.select :color_scheme, User.color_schemes.keys.map { |k| [k.titleize, k] } %>
      <small>System follows your device settings</small>

      <label for="user_light_theme">Light Theme</label>
      <%= form.select :light_theme, User.light_themes.keys.map { |k| [k.titleize.gsub("Selenized ", ""), k] } %>

      <label for="user_dark_theme">Dark Theme</label>
      <%= form.select :dark_theme, User.dark_themes.keys.map { |k| [k.titleize.gsub("Selenized ", ""), k] } %>
    </fieldset>

    <%= form.submit "Save Preferences" %>
  <% end %>
ERB
