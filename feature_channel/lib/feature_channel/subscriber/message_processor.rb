# frozen_string_literal: true

module FeatureChannel
  module Subscriber
    class MessageProcessor
      OPERATIONS = {
        'CREATE' => :create_entity,
        'UPDATE' => :update_entity,
        'DELETE' => :delete_entity
      }.freeze

      def initialize(message:, model:)
        @model = model
        @message = message
      end

      def run!
        method(operation_callback).call(model: @model, params: entity_params)
      end

      private

      def entity_params
        return { 'id' => @message['id'] } unless need_service_fetch?

        fetch_entity(entity_url)
      end

      def entity_url
        id, service, feature = @message.values_at('id', 'service', 'feature')
        "#{FeatureChannel.services[service]}/#{feature}/#{id}"
      end

      def fetch_entity(url)
        response = open(url)
        JSON.parse(response.read)
      end

      def need_service_fetch?
        %w[CREATE UPDATE].include? @message['type']
      end

      def operation_callback
        OPERATIONS[@message['type']]
      end

      def create_entity(model:, params:)
        model.create(params.slice(*model.column_names))
      end

      def update_entity(model:, params:)
        entity = model.find(params['id'])
        entity&.update(params.slice(*model.column_names))
      end

      def delete_entity(model:, params:)
        entity = model.find(params['id'])
        entity&.delete
      end
    end
  end
end
