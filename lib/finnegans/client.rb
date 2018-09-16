require "finnegans/core/request"
require "finnegans/core/authentication"

module Finnegans
  class Client
    include Finnegans::Core::Request
    include Finnegans::Core::Authentication

    attr_reader :client_id, :base_url, :api_catalog_path, :namespace

    def initialize(client_id:, client_secret:, base_url:, access_token: nil, api_catalog_path: 'apicatalog', namespace: Finnegans.resources_namespace)
      @client_id = client_id.to_s
      @client_secret = client_secret.to_s
      @base_url = base_url.to_s.gsub(/\/+$/, '')
      @access_token = access_token
      @api_catalog_path = api_catalog_path

      namespace = namespace.to_s
      @namespace = (namespace.empty? ? nil : namespace)

      self
    end

    def inspect
      self
    end

    def initialize_namespaced_resources(refresh: false)
      remove_previous_resources if refresh

      _namespaced_catalog = namespaced_catalog(refresh: refresh)

      _namespaced_catalog.each do |catalog_item|
        define_resource(catalog_item)
      end
    end

    def request(resource, request_params = {})
      unless request_params.is_a?(Hash)
        raise ArgumentError, 'The second argument in the :request must be a Hash ({}) ' \
          'or nil. Definition -> request(resource, request_params = {})'
      end

      authenticated_request do
        request_params[:params] = (request_params[:params] || {}).merge(authenticated_param)
        response = request_call(resource, request_params)
        body = json_load(response.body)

        response.success? ? body : (raise RequestError.new(body), body['error'])
      end
    end

    def catalog_detail(id)
      request("/#{@api_catalog_path}/#{id}")
    end

    private

    attr_reader :client_secret, :access_token

    def access_token=(value)
      @access_token = value
    end

    def authenticate
      begin
        authenticate!
      rescue Finnegans::AuthenticationError => e
        nil
      end
    end

    def authenticate!
      return if ready?

      (self.access_token = get_access_token) && nil
    end

    def ready?
      !!access_token
    end

    def catalog(refresh: false)
      return @_catalog if defined?(@_catalog) && !refresh

      @_catalog = request("/#{@api_catalog_path}/list")
    end

    def namespaced_catalog(refresh: false)
      return @_namespaced_catalog if defined?(@_namespaced_catalog) && !refresh

      @_namespaced_catalog = catalog(refresh: refresh).select do |catalog_item|
        namespace.nil? || catalog_item['codigo'] =~ /#{namespace}/i
      end
    end

    def authenticated_request(&block)
      authenticate! unless ready?

      begin
        yield
      rescue Finnegans::RequestError => error
        if error.message =~ /(invalid_token)/i
          ready? ? refresh_authentication! : authenticate!
          retry
        else
          raise error
        end
      end
    end

    def refresh_authentication!
      self.access_token = refresh_access_token
    end

    def defined_resources
      @_defined_resources ||= []
    end

    def remove_previous_resources
      defined_resources.delete_if do |resource_name|
        if respond_to?(resource_name.to_sym)
          (class << self; self; end).class_eval do
            remove_method resource_name.to_sym
          end
        end
        if instance_variable_defined?("@_#{resource_name}")
          send(:remove_instance_variable, :"@_#{resource_name}")
        end
        true
      end
    end

    def define_resource(data)
      resource_code = data['codigo']
      resource_name = Support.snakecase(resource_code.gsub(/#{namespace}/, ''))
      resource_active = data['activo']

      resource = Resource.new(code: resource_code, active: resource_active, client: self)
      instance_variable_set("@_#{resource_name}", resource)

      (class << self; self; end).class_eval do
        define_method :"#{resource_name}" do
          instance_variable_get("@_#{resource_name}")
        end
      end

      defined_resources << resource_name.to_sym
    end

  end
end
