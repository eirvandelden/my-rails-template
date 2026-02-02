# Home controller and view

# Generate Home controller
generate :controller, "Home", "index", "--skip-routes"

# Completely rewrite home view
remove_file "app/views/home/index.html.erb"
create_file "app/views/home/index.html.erb", <<~ERB
  <h1>Welcome</h1>

  <% if authenticated? %>
    <p>You are signed in as <%= Current.user.email %> (<%= Current.user.role.titleize %>)</p>

    <% if Current.user.admin? %>
      <p><%= link_to "Admin Panel", admin_users_path %></p>
    <% end %>

    <%= button_to "Sign out", session_path, method: :delete %>
  <% else %>
    <p><%= link_to "Sign in", new_session_path %></p>
  <% end %>
ERB

# Update application layout - use semantic HTML, no classes
remove_file "app/views/layouts/application.html.erb"
create_file "app/views/layouts/application.html.erb", <<~ERB
  <!DOCTYPE html>
  <html<%= tag.attributes(theme_attributes.merge("data-controller": "theme")) %>>
    <head>
      <title><%= content_for(:title) || Rails.application.class.module_parent_name %></title>
      <meta name="viewport" content="width=device-width,initial-scale=1">
      <%= csrf_meta_tags %>
      <%= csp_meta_tag %>
      <%= yield :head %>

      <%= stylesheet_link_tag :all, "data-turbo-track": "reload" %>
      <%= javascript_importmap_tags %>
    </head>

    <body>
      <header>
        <nav>
          <%= link_to_unless_current "Home", root_path %>
          <% if authenticated? %>
            <%= link_to_unless_current "Preferences", edit_preferences_path %>
            <% if Current.user.admin? %>
              <%= link_to_unless_current "Admin", admin_users_path %>
            <% end %>
            <%= button_to "Sign out", session_path, method: :delete %>
          <% else %>
            <%= link_to_unless_current "Sign in", new_session_path %>
          <% end %>
        </nav>
      </header>

      <main>
        <% if flash[:notice] %>
          <p role="status"><%= flash[:notice] %></p>
        <% end %>

        <% if flash[:alert] %>
          <p role="alert"><%= flash[:alert] %></p>
        <% end %>

        <%= yield %>
      </main>

      <footer>
        <p>&copy; <%= Date.current.year %> <%= Rails.application.class.module_parent_name %></p>
      </footer>
    </body>
  </html>
ERB
