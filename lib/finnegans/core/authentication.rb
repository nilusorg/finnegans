module Finnegans
  module Core

    module Authentication
      AUTH_PATH = '/oauth/token'.freeze
      private_constant :AUTH_PATH

      private

      def get_access_token
        request_params = {
          method: :get,
          params: auth_common_params.merge({grant_type: 'client_credentials'})
        }

        auth_request(request_params)
      end

      def refresh_access_token
        request_params = {
          method: :get,
          params: auth_common_params.merge({
            grant_type: 'refresh_token',
            refresh_token: @access_token
          })
        }

        auth_request(request_params)
      end

      def auth_request(request_params)
        response = request_call(AUTH_PATH, request_params)

        body = json_load(response.body)

        response.success? ? body : (raise AuthenticationError.new(body), body['error'])
      end

      def auth_common_params
        {
          client_id: @client_id,
          client_secret: @client_secret
        }
      end

      def authenticated_param
        # For the Finnegan API the params are case sensitive and this should be in all caps
        { "ACCESS_TOKEN" => @access_token }
      end
    end
  end
end
