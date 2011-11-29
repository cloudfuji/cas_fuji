module CasFuji
  class << self
    extend ActiveSupport::Memoizable

    def config_file_path
      ENV["CAS_FUJI_CONFIG"] || "./config/config.yml"
    end

    def config_file
      File.read(config_file_path)
    end

    def render_config_file
      ERB.new(config_file).result
    end

    def config
      YAML.load(render_config_file)[ENV["RACK_ENV"]]
    end

    memoize :config
  end
end
