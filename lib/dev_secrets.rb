module DevSecrets
  GLOB = "secrets*.yml{,.enc}"
  GLOB_ENC = "secrets*.yml.enc"
  class Railtie < ::Rails::Railtie
    initializer "dev_secrets.set_secrets_glob_pattern" do |app|
      app.config.paths["config/secrets"].glob = DevSecrets::GLOB
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

    def _dev_secrets_read_for_editing
      path, contents = _dev_secrets_read_first
      tmp_path = File.join(Dir.tmpdir, File.basename(path))
      IO.binwrite(tmp_path, contents)

      puts "Editing #{path}"
      yield tmp_path

      _dev_secrets_write(path, File.read(tmp_path))
    ensure
      FileUtils.rm(tmp_path) if File.exist?(tmp_path)
    end

    alias read_for_editing_original read_for_editing
    alias read_for_editing _dev_secrets_read_for_editing

    private

    def _dev_secrets_read_first
      return_val = nil
      Dir.glob(@root.join("config", DevSecrets::GLOB_ENC)).each do |path|
        begin
          return_val = [path, decrypt(IO.binread(path))]
          break
        rescue ActiveSupport::MessageEncryptor::InvalidMessage
        end
      end
      return_val or raise ActiveSupport::MessageEncryptor::InvalidMessage # Nothing decrypted correctly
    end

    def _dev_secrets_write(path, contents)
      IO.binwrite("#{path}.tmp", encrypt(contents))
      FileUtils.mv("#{path}.tmp", path)
    end

    def _dev_secrets_parse_file(path, env, all_secrets)
      require "erb"
      secrets = YAML.load(ERB.new(preprocess(path)).result) || {}
      all_secrets.merge!(secrets["shared"].deep_symbolize_keys) if secrets["shared"]
      all_secrets.merge!(secrets[env].deep_symbolize_keys) if secrets[env]
    end

  end
end
