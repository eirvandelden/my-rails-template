# Current class for thread-safe request context

create_file "app/models/current.rb", <<~RUBY
  class Current < ActiveSupport::CurrentAttributes
    attribute :user, :session
  end
RUBY
