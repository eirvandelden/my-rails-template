# Admin panel for user management

# Generate Admin namespace for user management
generate :controller, "Admin::Users", "index", "show", "edit", "update", "destroy", "--skip-routes"

# Create Admin base controller
create_file "app/controllers/admin/base_controller.rb", <<~RUBY
  class Admin::BaseController < ApplicationController
    before_action :ensure_admin

    layout "admin"
  end
RUBY

# Completely rewrite Admin::UsersController
remove_file "app/controllers/admin/users_controller.rb"
create_file "app/controllers/admin/users_controller.rb", <<~RUBY
  class Admin::UsersController < Admin::BaseController
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    def index
      @users = User.all.order(created_at: :desc)
    end

    def show
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: t(".success")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == Current.user
        redirect_to admin_users_path, alert: t(".cannot_delete_self")
      else
        @user.destroy
        redirect_to admin_users_path, notice: t(".success")
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :role)
    end
  end
RUBY

# Remove generated views and create our own
remove_file "app/views/admin/users/index.html.erb"
remove_file "app/views/admin/users/show.html.erb"
remove_file "app/views/admin/users/edit.html.erb"
remove_file "app/views/admin/users/update.html.erb"
remove_file "app/views/admin/users/destroy.html.erb"

create_file "app/views/admin/users/index.html.erb", <<~ERB
  <h1><%= t(".title") %></h1>

  <table>
    <thead>
      <tr>
        <th><%= t(".email") %></th>
        <th><%= t(".role") %></th>
        <th><%= t(".created_at") %></th>
        <th><%= t(".actions") %></th>
      </tr>
    </thead>
    <tbody>
      <% @users.each do |user| %>
        <tr>
          <td><%= user.email %></td>
          <td><%= user.role %></td>
          <td><%= l(user.created_at, format: :long) %></td>
          <td>
            <%= link_to t(".view"), admin_user_path(user) %>
            <%= link_to t(".edit"), edit_admin_user_path(user) %>
            <%= button_to t(".delete"), admin_user_path(user), method: :delete, data: { turbo_confirm: t(".confirm_delete") } unless user == Current.user %>
          </td>
        </tr>
      <% end %>
    </tbody>
  </table>
ERB

create_file "app/views/admin/users/show.html.erb", <<~ERB
  <h1><%= t(".title") %></h1>

  <dl>
    <dt><%= t(".email") %></dt>
    <dd><%= @user.email %></dd>

    <dt><%= t(".role") %></dt>
    <dd><%= @user.role %></dd>

    <dt><%= t(".created_at") %></dt>
    <dd><%= l(@user.created_at, format: :long) %></dd>

    <dt><%= t(".active_sessions") %></dt>
    <dd><%= @user.sessions.count %></dd>
  </dl>

  <nav>
    <%= link_to t(".edit"), edit_admin_user_path(@user) %>
    <%= link_to t(".back"), admin_users_path %>
  </nav>
ERB

create_file "app/views/admin/users/edit.html.erb", <<~ERB
  <h1><%= t(".title") %></h1>

  <%= form_with model: @user, url: admin_user_path(@user) do |form| %>
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
      <label for="user_email"><%= t(".email") %></label>
      <%= form.email_field :email, required: true %>

      <label for="user_role"><%= t(".role") %></label>
      <%= form.select :role, User.roles.keys.map { |r| [r, r] }, {}, required: true %>
    </fieldset>

    <nav>
      <%= form.submit t(".submit") %>
      <%= link_to t(".cancel"), admin_user_path(@user) %>
    </nav>
  <% end %>
ERB

# Create admin layout - semantic HTML, no classes
create_file "app/views/layouts/admin.html.erb", <<~ERB
  <!DOCTYPE html>
  <html lang="<%= I18n.locale %>" <%= tag.attributes(theme_attributes) %>>
    <head>
      <title><%= t("admin.title") %> - <%= Rails.application.class.module_parent_name %></title>
      <meta name="viewport" content="width=device-width,initial-scale=1">
      <meta name="turbo-cache-control" content="no-cache">
      <%= csrf_meta_tags %>
      <%= csp_meta_tag %>

      <%= stylesheet_link_tag :all, "data-turbo-track": "reload" %>
      <%= javascript_importmap_tags %>
    </head>

    <body>
      <header>
        <nav>
          <%= link_to t("admin.nav.dashboard"), root_path %>
          <%= link_to t("admin.nav.users"), admin_users_path %>
          <%= link_to t("admin.nav.back_to_site"), root_path %>
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
    </body>
  </html>
ERB
