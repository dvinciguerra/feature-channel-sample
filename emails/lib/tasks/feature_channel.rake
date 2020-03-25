# frozen_string_literal: true

require 'open-uri'

$stdout.sync = true

FEATURE_CHANNEL = 'feature_channel'

def redis_instance
  @redis_instance ||= Redis.new
end

Rails.logger = Logger.new(STDOUT)
Rails.logger.level = :info

namespace :feature_channel do
  desc 'feature channel taskes'

  task subscribe: :environment do
    services = {
      "assets" => "http://127.0.0.1:3003",
    }

    model_relations = {
      "assets" => Asset
    }

    logger = Rails.logger
    redis_instance.subscribe(FEATURE_CHANNEL) do |on|
      on.message do |channel, message|
        payload = MessagePack.unpack(message)

        puts payload
        logger.debug(payload)

        service, feature, id, type = payload.values_at("service", "feature", "id", "type")
        model_klass = model_relations[feature]

        # getting feature data
        need_service_fetch = %W(CREATE UPDATE).include? type

        # make the right operation
        if need_service_fetch
          response = open("#{services[service]}/#{feature}/#{id}")

          feature_entity = JSON.parse(response.read)
          name, description, bucket_url = feature_entity.values_at("name", "description", "bucket_url")

          # create operation
          if type == "CREATE"
            model_klass.create(id: id, name: name, description: description, bucket_url: bucket_url)
          end

          # update operation
          if type == "UPDATE"
            model = model_klass.find(id)
            model.update(name: name, description: description, bucket_url: bucket_url) if model
          end
        end

        # delete operation
        if type == "DELETE"
          model = model_klass.find(id)
          model.delete if model
        end
      rescue StandardError => err
        pp err
      end
    end
  end
end
