# frozen_string_literal: true

# app/channels/messages_channel.rb
class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'notification_channel'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak; end
end
