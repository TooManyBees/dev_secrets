module DevSecrets
  class Railtie < ::Rails::Railtie
    initializer "dev_secrets.set_secrets_glob_pattern" do |app|
      app.config.paths["config/secrets"].glob = "secrets*.yml{,.enc}"
    end
  end
end

module Rails
  Secrets.instance_eval do
    require "active_support/message_encryptor"

    def _dev_secrets_parse(paths, env:)
      all_secrets = Hash.new
      valid_encrypted_secrets_file = false
      invalid_message = false

      paths_enc, paths_plain = paths.partition { |path| path.end_with?(".enc") }

      paths_plain.each do |path|
        _dev_secrets_parse_file(path, env, all_secrets)
      end

      paths_enc.each do |path|
        begin
          _dev_secrets_parse_file(path, env, all_secrets)
          valid_encrypted_secrets_file = true
        rescue ActiveSupport::MessageEncryptor::InvalidMessage
          invalid_message = true
        end
      end

      # If at least one encrypted secrets file was loaded, then ignore the
      # exceptions from any failures.
      raise ActiveSupport::MessageEncryptor::InvalidMessage if invalid_message && !valid_encrypted_secrets_file
      all_secrets
    end

    alias parse_original parse
    alias parse _dev_secrets_parse

    private

    def _dev_secrets_parse_file(path, env, all_secrets)
      require "erb"
      secrets = YAML.load(ERB.new(preprocess(path)).result) || {}
      all_secrets.merge!(secrets["shared"].deep_symbolize_keys) if secrets["shared"]
      all_secrets.merge!(secrets[env].deep_symbolize_keys) if secrets[env]
    end

  end
end
