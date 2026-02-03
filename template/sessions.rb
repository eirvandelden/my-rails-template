# Sessions controller and views

# Generate Sessions controller
generate :controller, "Sessions", "new", "create", "destroy", "--skip-routes"

# Completely rewrite Sessions controller
remove_file "app/controllers/sessions_controller.rb"
create_file "app/controllers/sessions_controller.rb", <<~RUBY
  class SessionsController < ApplicationController
    allow_unauthenticated_access only: [:new, :create]

    def new
    end

    def create
      if user = User.authenticate_by(email: params[:email], password: params[:password])
        start_new_session_for(user)
        redirect_to after_authentication_url, notice: t(".success")
      else
        flash.now[:alert] = t(".failure")
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      terminate_session
      redirect_to root_path, notice: t(".success")
    end
  end
RUBY

# Completely rewrite sign in form
remove_file "app/views/sessions/new.html.erb"
create_file "app/views/sessions/new.html.erb", <<~ERB
  <h1><%= t(".title") %></h1>

  <%= form_with url: session_path do |form| %>
    <fieldset>
      <label for="email"><%= t(".email") %></label>
      <%= form.email_field :email, required: true, autofocus: true %>

      <label for="password"><%= t(".password") %></label>
      <%= form.password_field :password, required: true %>
    </fieldset>

    <%= form.submit t(".submit") %>
  <% end %>
ERB
