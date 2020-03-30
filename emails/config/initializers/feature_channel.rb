# frozen_string_literal: true

require_relative '../../lib/feature_channel.rb'

feature_channel_config = YAML.load_file(Rails.root.join('config', 'feature_channel.yml'))
topic, service_name, services, features = feature_channel_config.values_at('topic', 'name', 'services', 'features')

FeatureChannel.configure do |config|
  config.topic = topic

  config.services = services
  config.features = features

  config.service_name = service_name

  config.delivery_strategy ||= Redis.new
end
