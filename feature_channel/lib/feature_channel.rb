# frozen_string_literal: true

require 'feature_channel/version'
require 'feature_channel/publisher'
require 'feature_channel/subscriber'

module FeatureChannel
  class Error < StandardError; end

  class << self
    attr_accessor :topic, :features, :services, :service_name,
                  :delivery_strategy

    def configure
      yield(self)
    end
  end
end
