require "log"

abstract class EnvConfig
  Log = ::Log.for("env-config")

  # ameba:disable Metrics/CyclomaticComplexity
  def self.read_env_variable(key, **options)
    value = ENV.fetch(key, options[:default]?.to_s || "")
    if options[:optional]? != true && value.empty?
      puts "ERROR: expected environment variable: #{key}"
      puts "Description: #{options[:description]}" if options[:description]
      puts "Example: #{options[:example]?}" if options[:example]?
      puts "Default: #{options[:default]?}" if options[:default]?
      terminate_handler!(key)
    end

    supported_types = {Int32, String}
    if options[:type]? && !supported_types.includes?(options[:type]?)
      raise "Got unsupported type=#{options[:type]?} (must one of #{supported_types})"
    end

    options[:regexp]?.try do |format|
      unless format.match(value)
        puts "ERROR: environment variable #{key} is ill-formed (got: <<#{value}>>, but expected: #{format.source})"
        puts "Description: #{options[:description]}" if options[:description]
        puts "Example: #{options[:example]?}" if options[:example]?
        puts "Default: #{options[:default]?}" if options[:default]?
        terminate_handler!(key)
      end
    end

    if value.empty?
      Log.info { "#{key} => (not set)" }
    else
      Log.info { "#{key} => #{value}" }
    end

    if options[:type]? == Int32
      value.to_i
    else
      value
    end
  end

  macro expect_env(name, **options)
    {{name}} = read_env_variable "{{name}}", {{options.double_splat}}
  end

  macro config(conf = "config")
    Log.info { "# %s begin" % {{ conf }} }
    {{ yield }}
    Log.info { "# %s end\n" % {{ conf }} }
  end

  # predefined matchers:
  NUMBER = /^[0-9]+$/

  # If you do not want to exit, you can override the function. But note that
  # the error is by design unrecoverable. You can throw an exception instead,
  # but the config will be in an undefined state.
  #
  # Typically, there should be no reason to overwrite it. It primarily
  # exists to make the code testable.
  protected def self.terminate_handler!(key : String) : Nil
    Process.exit(1)
  end
end
