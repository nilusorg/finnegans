module Finnegans
  class Resource

    class ActionError < StandardError; end

    ACTIONS_MAP = {
      'SoportaDelete' => :delete,
      'SoportaGet' => :get,
      'SoportaInsert' => :insert,
      'SoportaList' =>  :list,
      'SoportaUpdate' => :update
    }.freeze
    private_constant :ACTIONS_MAP

    TYPE_NAMES = %i[ entity viewer java_class ].freeze
    private_constant :TYPE_NAMES

    attr_reader :code, :active

    def initialize(code:, active:, client:, with_details: false)
      @code = code
      @active = active
      @_client = client
      get_details if with_details
    end

    alias active? active

    def type
      return @_type if defined?(@_type)

      _type_index = (details['Tipo']).to_i

      @type = TYPE_NAMES[_type_index]
    end

    def actions
      return @_actions if defined?(@_actions)

      @_actions = details.map do |(_key, _value)|
        next unless _action = ACTIONS_MAP[_key]

        _action if _value
      end.compact
    end

    def create(body)
      ensure_type!(:entity)

      unless actions.include?(:get)
        raise ActionError.new, "The :get action is not available for this resource. Only #{actions} are available"
      end

      client.request("/#{code}", body: body.to_json, headers: { 'Content-Type' => 'application/json' }, method: :post)
    end

    def get(resource_id)
      ensure_type!(:entity)

      unless actions.include?(:get)
        raise ActionError.new, "The :get action is not available for this resource. Only #{actions} are available"
      end

      client.request("/#{code}/#{resource_id}")
    end

    def list
      ensure_type!(:entity)

      unless actions.include?(:list)
        raise ActionError.new, "The :get action is not available for this resource. Only #{actions} are available"
      end

      client.request("/#{code}/list")
    end

    def reports(**report_params)
      ensure_type!(:viewer)

      request_params = {
        params: { "PARAMWEBREPORT_MonedaID" => "PES" }.merge(report_params)
      }

      client.request("/reports/#{code}", request_params)
    end

    private

    def client
      @_client
    end

    def details
      @_details ||= get_details
    end

    def get_details(refresh: false)
      return @_details if defined?(@_details) && !refresh

      _details = client.catalog_detail(code)
      _details.delete('DefinitionXml')
      @_details = _details
    end

    def ensure_type!(type_name)
      unless type == type_name.to_sym
        raise ActionError.new, "This action is only available for resources that are type :#{type_name}"
      end
    end

  end
end
