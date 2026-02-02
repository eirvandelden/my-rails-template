# Rails Application Template
# Usage: rails new myapp -m template.rb
# Target: Rails 8.1+

# Get the directory where this template is located
TEMPLATE_ROOT = File.expand_path(File.dirname(__FILE__))

# Apply modular template components
apply "#{TEMPLATE_ROOT}/template/gems.rb"

after_bundle do
  apply "#{TEMPLATE_ROOT}/template/solid.rb"
  apply "#{TEMPLATE_ROOT}/template/current.rb"
  apply "#{TEMPLATE_ROOT}/template/authentication.rb"
  apply "#{TEMPLATE_ROOT}/template/authorization.rb"
  apply "#{TEMPLATE_ROOT}/template/models.rb"
  apply "#{TEMPLATE_ROOT}/template/sessions.rb"
  apply "#{TEMPLATE_ROOT}/template/preferences.rb"
  apply "#{TEMPLATE_ROOT}/template/admin.rb"
  apply "#{TEMPLATE_ROOT}/template/routes.rb"
  apply "#{TEMPLATE_ROOT}/template/home.rb"
  apply "#{TEMPLATE_ROOT}/template/email.rb"
  apply "#{TEMPLATE_ROOT}/template/css.rb"
  apply "#{TEMPLATE_ROOT}/template/theme_system.rb"
  apply "#{TEMPLATE_ROOT}/template/config.rb"
  apply "#{TEMPLATE_ROOT}/template/deployment.rb"
  apply "#{TEMPLATE_ROOT}/template/seeds.rb"
  apply "#{TEMPLATE_ROOT}/template/finish.rb"
end
