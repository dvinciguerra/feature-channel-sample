# frozen_string_literal: true

require 'msgpack'

module FeatureChannel
  module Publisher
    class << self
      def send_message(feature:, id:, type:, payload: nil)
        FeatureChannel.delivery_strategy.publish(
          FeatureChannel.topic,
          MessagePack.pack(
            service: FeatureChannel.service_name,
            feature: feature,
            id: id.to_s,
            type: type,
            payload: payload
          )
        )
      end
    end
  end
end
