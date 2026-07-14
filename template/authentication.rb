# Authentication system

# Set up Authentication concern
create_file "app/controllers/concerns/authentication.rb", <<~RUBY
  module Authentication
    extend ActiveSupport::Concern

    SESSION_COOKIE_LIFETIME = 1.year

    included do
      before_action :require_authentication
      before_action :set_locale
      helper_method :authenticated?
    end

    class_methods do
      def allow_unauthenticated_access(**options)
        skip_before_action :require_authentication, **options
      end
    end

    private

    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      if session_token = cookies.signed[:session_token]
        if session = Session.find_by(token: session_token)
          Current.session = session
          Current.user = session.user
          renew_session_cookie(session_token)
        end
      end
    end

    def renew_session_cookie(session_token)
      cookies.signed[:session_token] = {
        value: session_token,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax,
        expires: SESSION_COOKIE_LIFETIME.from_now
      }
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(user)
      session = user.sessions.create!(
        user_agent: request.user_agent,
        ip_address: request.remote_ip
      )
      user.update_column(:last_login_at, Time.current)

      Current.session = session
      Current.user = user
      cookies.signed[:session_token] = {
        value: session.token,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax,
        expires: SESSION_COOKIE_LIFETIME.from_now
      }

      session
    end

    def terminate_session
      Current.session&.destroy
      cookies.delete(:session_token)
    end

    def set_locale
      I18n.locale = Current.user&.locale || I18n.default_locale
      Time.zone = Current.user&.time_zone || Time.zone
    end
  end
RUBY
