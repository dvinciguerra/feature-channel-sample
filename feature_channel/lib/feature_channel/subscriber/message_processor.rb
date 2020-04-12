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
        @message['payload'].merge('id' => @message['id'])
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
