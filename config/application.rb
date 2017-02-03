require File.expand_path('../boot', __FILE__)

require 'active_support'
require 'active_model'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'
require 'matrix'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RubyGettingStarted
  class Application < Rails::Application

    config.time_zone = 'Brasilia'
    config.autoload_paths << Rails.root.join('services')
    config.i18n.enforce_available_locales = false
    config.i18n.default_locale = 'pt-BR'
    config.assets.enabled = true
    config.less.compress = true
    config.less.paths << "#{Rails.root}/vendor/assets/bower_components"
    config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')

  end
end
