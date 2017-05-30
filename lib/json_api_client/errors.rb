module JsonApiClient
  module Errors
    class ApiError < StandardError
      attr_reader :env
      def initialize(env)
        unless env[:body] && env[:body]["jsonapi"]
          @is_jsonapi = false
          @message = 'and the server\'s answer is not JSONAPI like'
        else
          @is_jsonapi = true
        end
        @env = env
      end

      # def params

      def message
        @message ||= (@is_jsonapi && "\n#{env.method.upcase} #{parsed_url.site + parsed_url.path}\n" +
        "\nREQUEST PARAMS\n#{parsed_url.query}\n#{JSON.pretty_generate(query_values)}\n" +
        "\nREQUEST BODY\n#{JSON.pretty_generate(request_body)}\n" +
        "\nRESPONSE\n#{JSON.pretty_generate(env.body)}") || ""
      end

      def parsed_url
        @parsed_url ||= Addressable::URI.parse(env.url.to_s)
      end

      def request_body
        @request_body ||= env[:request_body]
      end

      def query_values
        @query_values ||= parsed_url.query_values
      end

    end

    class ClientError < ApiError
    end

    class BadRequest < ClientError
    end

    class AccessDenied < ClientError
    end

    class NotAuthorized < ClientError
    end

    class ConnectionError < ApiError
    end

    class ServerError < ApiError
      def message
        "Internal server error" + super
      end
    end

    class Conflict < ServerError
      def message
        "Resource already exists" + super
      end
    end

    class NotFound < ServerError
      attr_reader :uri
      def initialize(env)
        super
        @uri = env[:uri]
      end
      def message
        "Couldn't find resource at: #{uri.to_s}" + super
      end
    end

    class UnexpectedStatus < ServerError
      attr_reader :code, :uri
      def initialize(code, env)
        super
        @code = code
        @uri = env[:uri]
      end
      def message
        "Unexpected response status: #{code} from: #{uri.to_s}" + super
      end
    end

  end
end
