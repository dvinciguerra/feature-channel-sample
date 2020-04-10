# frozen_string_literal: true

module FeatureChannel
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
end
