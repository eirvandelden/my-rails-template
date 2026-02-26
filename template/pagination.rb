say "Configuring geared_pagination...", :blue

# Include geared_pagination in ApplicationController
inject_into_file "app/controllers/application_controller.rb",
  after: "class ApplicationController < ActionController::Base\n" do
  <<~RUBY
  include GearedPagination::Controller

  RUBY
end

say "✓ geared_pagination configured", :green
say "  Usage: set_page_and_extract_portion_from Model.order(...)", :white
say "  In views: iterate over @page.records", :white
say "  Configure per_page at model level: self.per_page = 50", :white
