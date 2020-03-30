# frozen_string_literal: true

require 'open-uri'

$stdout.sync = true

def redis_instance
  @redis_instance ||= Redis.new
end

Rails.logger = Logger.new(STDOUT)
Rails.logger.level = :info

namespace :feature_channel do
  desc 'feature channel taskes'

  task subscribe: :environment do
    logger = Rails.logger

    redis_instance.subscribe(FeatureChannel.topic) do |on|
      on.message do |channel, message|
        FeatureChannel::Subscriber.process(channel, message)
      end
    end
  end
end
