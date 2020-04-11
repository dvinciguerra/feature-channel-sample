class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  after_create  :on_create_event
  after_update  :on_update_event
  after_destroy :on_delete_event

  private

  def feature_name
    self.class.to_s.downcase
  end

  def on_create_event
    FeatureChannel::Publisher.send_message(
      type: 'CREATE', feature: feature_name, id: id, payload: attributes
    )
  end

  def on_update_event
    FeatureChannel::Publisher.send_message(
      type: 'UPDATE', feature: feature_name, id: id, payload: attributes
    )
  end

  def on_delete_event
    FeatureChannel::Publisher.send_message(
      type: 'DELETE', feature: 'emails', id: id.to_s
    )
  end
end
