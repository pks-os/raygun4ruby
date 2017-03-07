module Raygun
  class Configuration

    def self.config_option(name)
      define_method(name) do
        read_value(name)
      end

      define_method("#{name}=") do |value|
        set_value(name, value)
      end
    end

    # Your Raygun API Key - this can be found on your dashboard at Raygun.io
    config_option :api_key

    # Array of exception classes to ignore
    config_option :ignore

    # Version to use
    config_option :version

    # Custom Data to send with each exception
    config_option :custom_data

    # Tags to send with each exception
    config_option :tags

    # Logger to use when we find an exception :)
    config_option :logger

    # Should we actually report exceptions to Raygun? (Usually disabled in Development mode, for instance)
    config_option :enable_reporting

    # Failsafe logger (for exceptions that happen when we're attempting to report exceptions)
    config_option :failsafe_logger

    # Which controller method should we call to find out the affected user?
    config_option :affected_user_method

    # Which methods should we try on the affected user object in order to get an identifier
    config_option :affected_user_identifier_methods

    # Which parameter keys should we filter out by default?
    config_option :filter_parameters

    # Should we switch to a white listing mode for keys instead of the default blacklist?
    config_option :filter_payload_with_whitelist

    # If :filter_payload_with_whitelist is true, which keys should we whitelist?
    config_option :whitelist_payload_keys

    # Hash of proxy settings - :address, :port (defaults to 80), :username and :password (both default to nil)
    config_option :proxy_settings

    # Exception classes to ignore by default
    IGNORE_DEFAULT = ['ActiveRecord::RecordNotFound',
                      'ActionController::RoutingError',
                      'ActionController::InvalidAuthenticityToken',
                      'ActionDispatch::ParamsParser::ParseError',
                      'CGI::Session::CookieStore::TamperedWithCookie',
                      'ActionController::UnknownAction',
                      'AbstractController::ActionNotFound',
                      'Mongoid::Errors::DocumentNotFound']

    DEFAULT_FILTER_PARAMETERS = [ :password, :card_number, :cvv ]



    DEFAULT_WHITELIST_PAYLOAD_KEYS = [
      :machineName,
      :version,
      :error,
      :className,
      :message,
      :stackTrace,
      :userCustomData,
      :tags,
      :request,
      :hostName,
      :url,
      :httpMethod,
      :iPAddress,
      :queryString,
      :headers,
      :form,
      :rawData
    ]

    attr_reader :defaults

    def initialize
      @config_values = {}

      # set default attribute values
      @defaults = OpenStruct.new({
        ignore:                           IGNORE_DEFAULT,
        custom_data:                      {},
        tags:                             [],
        enable_reporting:                 true,
        affected_user_method:             :current_user,
        affected_user_identifier_methods: [ :email, :username, :id ],
        filter_parameters:                DEFAULT_FILTER_PARAMETERS,
        filter_payload_with_whitelist:    false,
        whitelist_payload_keys:           DEFAULT_WHITELIST_PAYLOAD_KEYS,
        proxy_settings:                   {}
      })
    end

    def [](key)
      read_value(key)
    end

    def []=(key, value)
      set_value(key, value)
    end

    def silence_reporting
      !enable_reporting
    end

    def silence_reporting=(value)
      self.enable_reporting = !value
    end

    def filter_parameters(&filter_proc)
      set_value(:filter_parameters, filter_proc) if block_given?
      read_value(:filter_parameters)
    end

    def whitelist_payload_keys(&filter_proc)
      set_value(:whitelist_payload_keys, filter_proc) if block_given?
      read_value(:whitelist_payload_keys)
    end

    private

      def read_value(name)
        if @config_values.has_key?(name)
          @config_values[name]
        else
          @defaults.send(name)
        end
      end

      def set_value(name, value)
        @config_values[name] = value
      end

  end
end
