say "Configuring geared_pagination...", :blue

# Include geared_pagination in ApplicationController
inject_into_file "app/controllers/application_controller.rb",
  after: "class ApplicationController < ActionController::Base\n" do
  <<~RUBY
  include GearedPagination::Controller

  RUBY
end

# Update admin users controller to use geared_pagination
gsub_file "app/controllers/admin/users_controller.rb",
  /@users = User\.all/,
  "@users = User.order(created_at: :desc).page(params[:page]).per(50)"

say "✓ geared_pagination configured", :green
say "  Default: 50 items per page", :white
say "  Usage: Model.order(...).page(params[:page]).per(25)", :white
say "  In views: <%= paginate @records %>", :white
