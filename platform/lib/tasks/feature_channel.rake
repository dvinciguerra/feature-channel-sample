# frozen_string_literal: true

FEATURE_CHANNEL = 'feature_channel'

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
    redis_instance.subscribe(FEATURE_CHANNEL) do |on|
      on.message do |channel, message|
        payload = MessagePack.unpack(message)
        puts payload
        logger.debug(payload)
      rescue StandardError => err
        pp err
      end
    end
  end
end
