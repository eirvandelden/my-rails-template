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

# Include this concern in ApplicationController. Appkit::Authentication is
# included separately by template/appkit.rb (which runs after this module).
inject_into_class "app/controllers/application_controller.rb", "ApplicationController", <<~RUBY
  include Authorization
RUBY
