module Finnegans
  module Core
    module Request

      private

      def default_headers
        {
          "Accept-Encoding" => "application/json"
        }
      end

      def request_call(resource, request_params = {})
        unless request_params.is_a?(Hash)
          raise ArgumentError, 'The second argument in the :request_call must be a Hash ({}) ' \
            'or nil. Definition -> request_call(resource, request_params = {})'
        end

        request_params[:headers] = default_headers.merge(request_params[:headers] || {})
        request = Typhoeus::Request.new("#{@base_url}#{resource}", request_params)
        request.run
        request.response
      end

      def json_dump(hash)
        Oj.dump(hash)
      end

      def json_load(string)
        begin
          Oj.load(string)
        rescue Oj::ParseError => e
          string
        end
      end

    end
  end
end
