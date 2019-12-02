# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == %w[sidekiqadmin sidekiqadmin]
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end
