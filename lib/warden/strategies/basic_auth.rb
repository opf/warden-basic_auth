require 'warden'
require 'rack/auth/basic'

module Warden
  module Strategies
    class BasicAuth < Base
      def valid?
        request.provided? && request.basic? && request.credentials
      end

      def authenticate!
        user = authenticate_user username, password

        if user
          authentication_successful user
        else
          authentication_failed
        end
      end

      def authenticate_user(username, password)
        raise NotImplementedError
      end

      def authentication_successful(user)
        success! user
      end

      def authentication_failed
        headers 'WWW-Authenticate' => %(Basic realm="#{realm}")

        custom! [401, headers, 'unauthorized']
      end

      def store?
        false
      end

      def username
        request.credentials[0]
      end

      def password
        request.credentials[1]
      end

      def request
        @request ||= Rack::Auth::Basic::Request.new(env)
      end

      def realm
        'private area'
      end
    end
  end
end
