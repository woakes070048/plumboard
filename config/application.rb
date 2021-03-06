require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env)

module Plumboard
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths << "#{config.root}/lib"
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
    config.active_record.observers = :transaction_observer, :user_observer, 
      :invoice_observer, :post_observer, :comment_observer, :inquiry_observer, 
      :pixi_want_observer, :pixi_ask_observer  # , :listing_observer, :pixi_post_observer, :saved_listing_observer

    # Raise errors in `after_rollback`/`after_commit` callbacks
    config.active_record.raise_in_transactional_callbacks = true

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = true

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.5'

    # Devise view handler for user/signup
    config.paths['app/views'] << "app/views/devise"

    # don't generate RSpec tests for views and helpers
    config.generators do |g|
      g.view_specs false
      g.helper_specs false
    end

    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins *(['localhost', 'staging.pixiboard.com',
                   'pixiboard.com', 'rippleapi.herokuapp.com'] +
                   Socket.ip_address_list.map(&:ip_address))
        resource '*', :headers => :any, :methods => :any
      end
    end

    # Use Delayed::Job for ActiveJob queueing
    config.active_job.queue_adapter = :delayed_job
  end
end
