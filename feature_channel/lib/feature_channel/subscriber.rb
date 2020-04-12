# frozen_string_literal: true

require 'msgpack'
require 'feature_channel/subscriber/message_processor'

module FeatureChannel
  module Subscriber
    class << self
      def process(topic, message)
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
  end
end
