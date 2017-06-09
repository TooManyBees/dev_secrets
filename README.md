# DevSecrets

Rails 5.1 introduced encrypted secrets, a way of keeping your applciation's
secret tokens safely in the repository where they belong, without actually
committing them in a readable form.

This gem allows your app to have multiple secrets files matching the
file glob `secrets*.yml{,.enc}`, so you can store encrypted secrets for
different environments.

### But aren't the secrets YML files already formatted to support multiple environments?

The problem this solves is individual developers using encrypted secrets locally.
The local Rails server may rely on accessing a remote resource, but even for throwaway
dev accounts, you might not want to commit those secrets in plaintext. So you use
encrypted secrets.

But you also have production secrets stored in the same encrypted file. Even if
you trust the people running the app locally in dev, you shouldn't need to give
them all the keys to, say, the S3 bucket containing your production client data.

This lets you drop multiple secrets files into the same app and then hand out the
appropriate decryption key.

## Usage
Add it to any Gemfile that also includes Rails >= 5.1. Commit your encrypted
secrets to any file matching the pattern `secrets*.yml.enc`. Your app's master
key (either in `ENV['RAILS_MASTER_KEY']` or the file `secrets.yml.key`) need
only decrypt one of them. When your app's secrets are loaded for the first time,
Rails will attempt to read all encrypted secrets, merging only the ones that
decrypt correctly.

Rails normally raises `ActiveSupport::MessageEncryptor::InvalidMessage` when
it attempts and fails to decrypt secrets. Because the expected behavior of
DevSecrets is to naturally fail to decrypt secrets that are for the wrong
environment, Rails will now swallow that error if at least one encrypted secrets
file was successfully parsed. If all parses fail, it will raise the exception as
expected.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'dev_secrets'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install dev_secrets
```

## Contributing
lol

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
