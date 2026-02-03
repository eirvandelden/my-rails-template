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
        redirect_to edit_preferences_path, notice: t(".success")
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
  <h1><%= t(".title") %></h1>

  <%= form_with model: @user, url: preferences_path do |form| %>
    <% if @user.errors.any? %>
      <aside role="alert">
        <h2><%= t("errors.template.header", count: @user.errors.count) %></h2>
        <ul>
          <% @user.errors.each do |error| %>
            <li><%= error.full_message %></li>
          <% end %>
        </ul>
      </aside>
    <% end %>

    <fieldset>
      <legend><%= t(".language") %></legend>

      <label for="user_locale"><%= t(".locale") %></label>
      <%= form.select :locale, User::AVAILABLE_LOCALES.map { |l| [t("locales.\#{l}"), l] } %>
    </fieldset>

    <fieldset>
      <legend><%= t(".appearance") %></legend>

      <label for="user_color_scheme"><%= t(".color_scheme") %></label>
      <%= form.select :color_scheme, User.color_schemes.keys.map { |k| [t("color_schemes.\#{k}"), k] } %>
      <small><%= t(".color_scheme_hint") %></small>

      <label for="user_light_theme"><%= t(".light_theme") %></label>
      <%= form.select :light_theme, User.light_themes.keys.map { |k| [t("themes.\#{k}"), k] } %>

      <label for="user_dark_theme"><%= t(".dark_theme") %></label>
      <%= form.select :dark_theme, User.dark_themes.keys.map { |k| [t("themes.\#{k}"), k] } %>
    </fieldset>

    <%= form.submit t(".submit") %>
  <% end %>
ERB
