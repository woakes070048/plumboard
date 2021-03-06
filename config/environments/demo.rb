require 'exception_notifier'
Plumboard::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  config.eager_load = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = false

  # Compress JavaScripts and CSS
  config.assets.js_compressor = :uglifier

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # set assets to expire
  config.assets.expire_after 2.weeks

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store
  # config.cache_store = :dalli_store, 'demo.pixiboard.com',
  #  { :namespace => 'Plumboard', :expires_in => 1.hour, :compress => true }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )
  # files = Dir[Rails.root.join('app', 'assets', '{javascripts,stylesheets}', '**', '[^_]*.{js,css}*')]
  # files.map! {|file| file.sub(%r(#{Rails.root}/app/assets/(javascripts|stylesheets)/), '') }
  # files.map! {|file| file.sub(%r(\.(coffee|scss)), '') }
  # config.assets.precompile += files
  # config.assets.precompile += ['.css', '.js', '.png', '.jpg', '.bmp', '.gif', '.ico']

  # Disable delivery errors, bad email addresses will be ignored
  ActionMailer::Base.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { :host => 'demo.pixiboard.com' }

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # set paperclip aws settings
  PAPERCLIP_STORAGE_OPTIONS = {:storage => :s3, 
                               :s3_credentials => YAML.load_file("#{Rails.root}/config/aws.yml")[Rails.env],
	  		       url: ":s3_domain_url",
			       path: ":attachment/:id_partition/:style/:filename"}

  config.paperclip_defaults = PAPERCLIP_STORAGE_OPTIONS 

  # facebook ssl setting
  FACEBOOK_SSL_OPTIONS = {:ca_file => '/etc/pki/tls/certs/ca-bundle.crt'}

  config.middleware.use ExceptionNotification::Rack,
    :email => {
      :email_prefix => "Pixiboard: ",
      :sender_address => %{"Pixiboard Admin" <webmaster@pixiboard.com>},
      :exception_recipients => %w{techsupport@pixiboard.com} 
    }
end
