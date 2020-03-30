# frozen_string_literal: true

module FeatureChannel
  class << self
    attr_accessor :topic, :features, :services, :service_name, :delivery_strategy

    def configure
      yield(self)
    end
  end

  module Publisher
    class << self
      def send_message(feature:, id:, type:, payload: nil)
        FeatureChannel.delivery_strategy.publish(
          FeatureChannel.topic,
          {
            service: FeatureChannel.service_name,
            feature: feature,
            id: id.to_s,
            type: type,
            payload: payload
          }.to_msgpack
        )
      end
    end
  end

  module Subscriber
    class << self
      def process(_topic, message)
        payload = message_decode(message)
        model = feature_model(payload['feature'])

        return unless accept_message? model

        processor =
          Subscriber::MessageProcessor.new(message: payload, model: model)

        processor.run!
      end

      private

      def accept_message?(model_klass)
        !!model_klass
      end

      def feature_model(feature)
        features = FeatureChannel.features
        features[feature] ? Object.const_get(features[feature]) : nil
      end

      def message_decode(message)
        MessagePack.unpack(message)
      end
    end

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
