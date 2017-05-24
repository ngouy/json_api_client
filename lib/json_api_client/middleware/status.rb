module JsonApiClient
  module Middleware
    class Status < Faraday::Middleware
      def call(environment)
        request_body = environment.body || {}.to_s
        @app.call(environment).on_complete do |env|
          env[:request_body] = JSON.parse(request_body)
          handle_status(env[:status], env)

          # look for meta[:status]
          if env[:body].is_a?(Hash)
            code = env[:body].fetch("meta", {}).fetch("status", 200).to_i
            handle_status(code, env)
          end
        end
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError
        raise Errors::ConnectionError, environment
      end

      protected

      def handle_status(code, env)
        case code
        when 200..399
        when 401
          raise Errors::NotAuthorized, env
        when 403
          raise Errors::AccessDenied, env
        when 404
          raise Errors::NotFound, env
        when 409
          raise Errors::Conflict, env
        when 400..499
          raise Errors::BadRequest, env
        when 500..599
          raise Errors::ServerError, env
        else
          raise Errors::UnexpectedStatus.new(code, env)
        end
      end
    end
  end
end
