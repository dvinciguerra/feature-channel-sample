# frozen_string_literal: true

require 'open-uri'

$stdout.sync = true

module FeatureChannel
  class << self
    attr_accessor :topic, :models, :services

    def configure
      yield(self)
    end
  end

  module Subscriber
    class << self
      def process(_topic, message)
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
        MODELS[feature] ? Object.const_get(MODELS[feature]) : nil
      end

      def message_decode(message)
        MessagePack.unpack(message)
      end
    end

    class MessageProcessor
      OPERATIONS = {
        'CREATE' => :create_entity,
        'UPDATE' => :update_entity,
        'DELETE' => :delete_entity
      }.freeze

      def initialize(message:, model:)
        @model = model
        @message = message
      end

      def run!
        method(operation_callback).call(model: @model, params: entity_params)
      end

      private

      def entity_params
        return { 'id' => @message['id'] } unless need_service_fetch?

        fetch_entity(entity_url)
      end

      def entity_url
        id, service, feature = @message.values_at('id', 'service', 'feature')
        "#{SERVICES[service]}/#{feature}/#{id}"
      end

      def fetch_entity(url)
        response = open(url)
        JSON.parse(response.read)
      end

      def need_service_fetch?
        %w[CREATE UPDATE].include? @message['type']
      end

      def operation_callback
        OPERATIONS[@message['type']]
      end

      def create_entity(model:, params:)
        model.create(params.slice(*model.column_names))
      end

      def update_entity(model:, params:)
        entity = model.find(params['id'])
        entity&.update(params.slice(*model.column_names))
      end

      def delete_entity(model:, params:)
        entity = model.find(params['id'])
        entity&.delete
      end
    end
  end
end

FEATURE_CHANNEL = 'feature_channel'

SERVICES = YAML.safe_load(<<-YAML)
  emails: http://127.0.0.1:3002
YAML

MODELS = YAML.safe_load(<<-YAML)
  emails: Email
YAML

def redis_instance
  @redis_instance ||= Redis.new
end

Rails.logger = Logger.new(STDOUT)
Rails.logger.level = :info

FeatureChannel.configure do |config|
  config.topic = FEATURE_CHANNEL

  config.models = MODELS

  config.services = SERVICES
end

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
