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
        redirect_to admin_user_path(@user), notice: "User updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == Current.user
        redirect_to admin_users_path, alert: "You cannot delete yourself"
      else
        @user.destroy
        redirect_to admin_users_path, notice: "User deleted successfully"
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
  <h1>User Management</h1>

  <table>
    <thead>
      <tr>
        <th>Email</th>
        <th>Role</th>
        <th>Created</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <% @users.each do |user| %>
        <tr>
          <td><%= user.email %></td>
          <td><%= user.role.titleize %></td>
          <td><%= user.created_at.to_fs(:long) %></td>
          <td>
            <%= link_to "View", admin_user_path(user) %>
            <%= link_to "Edit", edit_admin_user_path(user) %>
            <%= button_to "Delete", admin_user_path(user), method: :delete, data: { confirm: "Are you sure?" } unless user == Current.user %>
          </td>
        </tr>
      <% end %>
    </tbody>
  </table>
ERB

create_file "app/views/admin/users/show.html.erb", <<~ERB
  <h1>User Details</h1>

  <dl>
    <dt>Email</dt>
    <dd><%= @user.email %></dd>

    <dt>Role</dt>
    <dd><%= @user.role.titleize %></dd>

    <dt>Created</dt>
    <dd><%= @user.created_at.to_fs(:long) %></dd>

    <dt>Active Sessions</dt>
    <dd><%= @user.sessions.count %></dd>
  </dl>

  <nav>
    <%= link_to "Edit", edit_admin_user_path(@user) %>
    <%= link_to "Back", admin_users_path %>
  </nav>
ERB

create_file "app/views/admin/users/edit.html.erb", <<~ERB
  <h1>Edit User</h1>

  <%= form_with model: @user, url: admin_user_path(@user) do |form| %>
    <% if @user.errors.any? %>
      <aside role="alert">
        <h2><%= pluralize(@user.errors.count, "error") %> prohibited this user from being saved:</h2>
        <ul>
          <% @user.errors.each do |error| %>
            <li><%= error.full_message %></li>
          <% end %>
        </ul>
      </aside>
    <% end %>

    <fieldset>
      <label for="user_email">Email</label>
      <%= form.email_field :email, required: true %>

      <label for="user_role">Role</label>
      <%= form.select :role, User.roles.keys.map { |r| [r.titleize, r] }, {}, required: true %>
    </fieldset>

    <nav>
      <%= form.submit "Update User" %>
      <%= link_to "Cancel", admin_user_path(@user) %>
    </nav>
  <% end %>
ERB

# Create admin layout - semantic HTML, no classes
create_file "app/views/layouts/admin.html.erb", <<~ERB
  <!DOCTYPE html>
  <html>
    <head>
      <title>Admin - <%= Rails.application.class.module_parent_name %></title>
      <meta name="viewport" content="width=device-width,initial-scale=1">
      <meta name="turbo-cache-control" content="no-cache">
      <%= csrf_meta_tags %>
      <%= csp_meta_tag %>

      <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
      <%= javascript_importmap_tags %>
    </head>

    <body>
      <header>
        <nav>
          <%= link_to "Dashboard", root_path %>
          <%= link_to "Users", admin_users_path %>
          <%= link_to "Back to Site", root_path %>
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
