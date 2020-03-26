# frozen_string_literal: true

require 'open-uri'

$stdout.sync = true

FEATURE_CHANNEL = 'feature_channel'

SERVICES = YAML.load(<<-YAML)
  emails: http://127.0.0.1:3002
YAML

MODELS = YAML.load(<<-YAML)
  emails: Email
YAML

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
        message_payload = MessagePack.unpack(message)

        logger.debug(message_payload)

        service, feature, id, type = message_payload.values_at("service", "feature", "id", "type")
        model_klass = MODELS[feature] ? Object.const_get(MODELS[feature]) : nil

        # getting feature data
        accept_message = !!model_klass
        need_service_fetch = %W(CREATE UPDATE).include? type

        if accept_message
          # make the right operation
          if need_service_fetch
            logger.info("Getting entity info from \"#{SERVICES[service]}/#{feature}/#{id}\"...")
            response = open("#{SERVICES[service]}/#{feature}/#{id}")
            entity_params = JSON.parse(response.read)

            entity_attributes = model_klass.column_names

            # create operation
            if type == "CREATE"
              model_klass.create(entity_params.slice(*entity_attributes))
            end

            # update operation
            if type == "UPDATE"
              model = model_klass.find(id)
              model.update(entity_params.slice(*entity_attributes))
            end
          end

          # delete operation
          if type == "DELETE"
            model = model_klass.find(id)
            model.delete if model
          end
        end
      rescue StandardError => err
        pp err
      end
    end
  end
end
