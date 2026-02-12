say "Setting up custom validators...", :blue

# Create validators directory
empty_directory "app/validators"

# Create email validator
create_file "app/validators/email_validator.rb", <<~RUBY
  class EmailValidator < ActiveModel::Validator
    EMAIL_REGEX = URI::MailTo::EMAIL_REGEXP

    def validate(record)
      email = record.send(attribute_name)
      return if email.blank?

      unless email.match?(EMAIL_REGEX)
        record.errors.add(attribute_name, :invalid_email, value: email)
      end
    end
  end
RUBY

# Create URL validator
create_file "app/validators/url_validator.rb", <<~RUBY
  class UrlValidator < ActiveModel::Validator
    def validate(record)
      url = record.send(attribute_name)
      return if url.blank?

      begin
        URI.parse(url)
        uri = URI(url)
        unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
          record.errors.add(attribute_name, :invalid_url, value: url)
        end
      rescue URI::InvalidURIError
        record.errors.add(attribute_name, :invalid_url, value: url)
      end
    end
  end
RUBY

# Create README for validators
create_file "app/validators/README.md", <<~MD
  # Custom Validators

  This directory contains reusable custom validators for your models.

  ## Usage

  Add validators to your models:

  ```ruby
  class User < ApplicationRecord
    validates :email, presence: true, email: true
    validates :website, url: true, allow_blank: true
  end
  ```

  ## Built-in Validators

  ### EmailValidator

  Validates that a field contains a valid email address.

  ```ruby
  validates :email, email: true
  ```

  Options:
  - `allow_blank: true` - Allow blank values
  - `allow_nil: true` - Allow nil values

  ### UrlValidator

  Validates that a field contains a valid HTTP(S) URL.

  ```ruby
  validates :website, url: true
  ```

  Options:
  - `allow_blank: true` - Allow blank values
  - `allow_nil: true` - Allow nil values

  ## Creating Custom Validators

  Create a new file `app/validators/my_validator.rb`:

  ```ruby
  class MyValidator < ActiveModel::Validator
    def validate(record)
      value = record.send(attribute_name)

      if value.present? && !meets_criteria?(value)
        record.errors.add(attribute_name, :invalid, value: value)
      end
    end

    private

    def meets_criteria?(value)
      # Your validation logic here
    end
  end
  ```

  Use in models:

  ```ruby
  validates :field, my: true
  ```

  ## Resources

  - [Rails Validations Documentation](https://guides.rubyonrails.org/active_record_validations.html)
  - [Custom Validators Guide](https://guides.rubyonrails.org/active_record_validations.html#custom-validators)
MD

say "✓ Custom validators created", :green
say "  - EmailValidator: validates :email, email: true", :white
say "  - UrlValidator: validates :url, url: true", :white
