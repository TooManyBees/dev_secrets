require 'test_helper'

class DevSecrets::Test < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, DevSecrets
  end

  test "loads config/secrets.yml.enc" do
    assert_equal Rails.application.secrets.this_file_name, "secrets_dev.yml.enc"
  end
end
