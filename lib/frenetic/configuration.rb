class Frenetic
  class Configuration < Hash

    class ConfigurationError < StandardError; end

    # TODO: This is in desperate need of .with_indifferent_access...
    # TODO: "content-type" should probably be within a "headers" key
    def initialize( custom_config = {} )
      config = config_file.merge custom_config

      self[:url]      = config['url']     if config['url']
      self[:username] = config['api_key'] if config['api_key']
      self[:headers]  = config['headers'] || {}

      if config['content-type']
        self[:headers][:accepts] = config['content-type']
      else
        self[:headers][:accepts] = "application/hal+json"
      end

      super()

      validate_configuration
    end

  private

    def validate_configuration
      unless self[:url]
        raise ConfigurationError, "No API URL defined!"
      end
    end

    def config_file
      config_path = File.join( 'config', 'frenetic.yml' )

      if File.exists? config_path
        config = YAML.load_file( config_path )
        env    = ENV['RAILS_ENV'] || ENV['RACK_ENV']

        if config and config.has_key? env
          config[env]
        else
          {}
        end
      else
        {}
      end
    end

  end
end