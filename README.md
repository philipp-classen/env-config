# env-config

A minimalistic, opinionated Crystal library for managing configurations via environment variables.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     env-config:
       github: philipp-classen/env-config
   ```

2. Run `shards install`

## Usage

```crystal
require "env-config"

# This will define two variables. HOST will be of type `String` and PORT an `Int32`.
class Config < EnvConfig
  expect_env HOST, description: "Host of the server", default: "127.0.0.1"
  expect_env PORT, description: "Port of the server", default: 9101
end

p! Config::HOST # -> "127.0.0.1"
p! Config::PORT # -> 9101

# Wrapping it in `config` to get better logging
class Config2 < EnvConfig
  config do
    expect_env HOST, description: "Host of the server", default: "127.0.0.1"
    expect_env PORT, description: "Port of the server", default: 9101
  end
end

p! Config2::HOST # -> "127.0.0.1"
p! Config2::PORT # -> 9101

# Optionally, you use multiple block with a name. Again, it only affects logging.
class Config3 < EnvConfig
  config("http") do
    expect_env HOST, description: "Host of the server", default: "127.0.0.1"
    expect_env PORT, description: "Port of the server", default: 9101
  end

  config("output") do
    expect_env S3_PATH, description: "S3 output path", example: "s3://example-bucket/foo/bar"
    expect_env TEMP_DIR, description: "A directory to store temporary files", example: "/tmp"
  end
end

# Providing an example can make your error messages more readable-
class Config4 < EnvConfig
  expect_env KAFKA_BROKER, example: "10.3.0.3:9092", description: "A comma separated list of Kafka brokers."
end

p! Config4::KAFKA_BROKER

# If the environment variable is not set, it will fail with this error message:
#
# ERROR: expected environment variable: KAFKA_BROKER
# Description: A comma separated list of Kafka brokers.
# Example: 10.3.0.3:9092

# ----------------------------------------------------------------------

# Values can be validates with regular expression. If the target should be a number
# and there is no default, you can pass the `type` explicitly:
class Config5 < EnvConfig
  expect_env VERSION, description: "The version (a YYYY-MM-DD timestamp)", default: "2024-06-14", regexp: /^\d{4}-\d{2}-\d{2}$/
  expect_env NUM_WORKERS, description: "Number of workers", type: Int32, regexp: NUMBER # predefined as /^[0-9]+$/
end

p! Config5::VERSION
p! Config5::NUM_WORKERS.class # -> Int32

# If NUM_WORKERS=-1, it would fail with with this error message:
# ERROR: environment variable NUM_WORKERS is ill-formed (got: <<-1>>, but expected: ^[0-9]+$)
# Description: Number of workers
```

## Development

Use `crystal spec` to run unit tests.

## Contributing

1. Fork it (<https://github.com/philipp-classen/env-config/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Philipp Claßen](https://github.com/philipp-classen) - creator and maintainer
