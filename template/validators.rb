say "Setting up custom validators...", :blue

# Create validators directory
empty_directory "app/validators"

# Create email validator
create_file "app/validators/email_validator.rb", <<~RUBY
  # Validates that an attribute contains a valid email address.
  #
  # @example
  #   validates :email, email: true
  #   validates :contact_email, email: true, allow_blank: true
  class EmailValidator < ActiveModel::EachValidator
    EMAIL_REGEX = URI::MailTo::EMAIL_REGEXP

    # Validates a single attribute value.
    #
    # @param record [ActiveRecord::Base] the model being validated
    # @param attribute [Symbol] the attribute name being validated
    # @param value [String] the value to validate
    # @return [void]
    def validate_each(record, attribute, value)
      return if value.blank?

      unless value.match?(EMAIL_REGEX)
        record.errors.add(attribute, :invalid, value: value)
      end
    end
  end
RUBY

# Create URL validator
create_file "app/validators/url_validator.rb", <<~RUBY
  # Validates that an attribute contains a valid HTTP(S) URL.
  #
  # @example
  #   validates :website, url: true
  #   validates :homepage, url: true, allow_blank: true
  class UrlValidator < ActiveModel::EachValidator
    # Validates a single attribute value.
    #
    # @param record [ActiveRecord::Base] the model being validated
    # @param attribute [Symbol] the attribute name being validated
    # @param value [String] the value to validate
    # @return [void]
    def validate_each(record, attribute, value)
      return if value.blank?

      begin
        uri = URI.parse(value)
        unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
          record.errors.add(attribute, :invalid, value: value)
        end
      rescue URI::InvalidURIError
        record.errors.add(attribute, :invalid, value: value)
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
  class MyValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return if value.blank?

      unless meets_criteria?(value)
        record.errors.add(attribute, :invalid, value: value)
      end
    end

    private

    def meets_criteria?(value)
      # Your validation logic here
      true
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
