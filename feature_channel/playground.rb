# frozen_string_literal: true

# publish message

require 'feature_channel'

features = YAML.safe_load(<<~YAML)
  assets: Asset
  emails: Email
  subscriber: Subscriber
YAML

# feature_channel configuration
FeatureChannel.configure do |config|
  # define topic name
  config.topic = 'feature_channel'

  # features configuration
  config.features = features

  # on receive message
  config.on_receive :message do |feature, payload|

  end
end
