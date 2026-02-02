# Authorization system

# Set up Authorization concern with role-based checks
create_file "app/controllers/concerns/authorization.rb", <<~RUBY
  module Authorization
    extend ActiveSupport::Concern

    private

    def ensure_admin
      unless Current.user&.admin?
        redirect_to root_path, alert: "You must be an admin to access this page"
      end
    end
  end
RUBY

# Include concerns in ApplicationController
inject_into_class "app/controllers/application_controller.rb", "ApplicationController", <<~RUBY
  include Authentication
  include Authorization
RUBY
