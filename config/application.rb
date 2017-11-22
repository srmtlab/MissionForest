require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MissionForest
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
    config.active_record.raise_in_transactional_callbacks = true
    config.autoload_paths += %W(#{config.root}/lib)
    config.to_prepare do
      DeviseController.respond_to :html, :json
    end
  end
end
