Sidekiq.configure_server do |config|
  redis_url = ENV['REDIS_URL'] || 'redis://localhost:6379/0'
  config.redis = { url: redis_url }

  schedule_file = Rails.root.join('config', 'schedule.yml')
  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file))
  end
end

Sidekiq.configure_client do |config|
  redis_url = ENV['REDIS_URL'] || 'redis://localhost:6379/0'
  config.redis = { url: redis_url }
end