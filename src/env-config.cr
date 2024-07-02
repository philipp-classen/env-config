require "log"

abstract class EnvConfig
  Log = ::Log.for("env-config")

  def self.to_bool(flag : Bool) : Bool
    flag
  end

  def self.to_bool(flag : String) : Bool
    case flag.strip.downcase
    when "true", "1", "on", "enable", "enabled", "yes"
      true
    when "false", "0", "off", "disable", "disabled", "no"
      false
    else
      raise "Failed to parse boolean <<#{flag}>> (try \"true\" or \"false\" instead)"
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.read_env_variable(key, **options)
    if options[:optional]? != true && options[:default]?.nil? && ENV[key]?.nil?
      puts "ERROR: expected environment variable: #{key}"
      puts "Description: #{options[:description]}" if options[:description]
      puts "Example: #{options[:example]?}" if options[:example]?
      puts "Default: #{options[:default]?}" if options[:default]?
      return terminate_handler!(key)
    end
    value = ENV[key]?
    return options[:default]? if value.nil?

    supported_types = {String, Bool, Int32, Int64, Float32, Float64}
    if options[:type]? && !supported_types.includes?(options[:type]?)
      raise "Got unsupported type=#{options[:type]?} (must one of #{supported_types})"
    end

    target =
      if options[:type]?
        options[:type]?
      elsif !options[:default]?.nil?
        options[:default]?.class
      else
        String
      end

    regexp = options[:regexp]?
    if !regexp && target == Bool
      regexp = FLAG
    end

    regexp.try do |format|
      unless format.match(value.to_s)
        puts "ERROR: environment variable #{key} is ill-formed (got: <<#{value}>>, but expected: #{pretty_regexp(format)})"
        puts "Description: #{options[:description]}" if options[:description]
        puts "Example: #{options[:example]?}" if options[:example]?
        puts "Default: #{options[:default]?}" if options[:default]?
        return terminate_handler!(key)
      end
    end

    result =
      if target == String
        value
      elsif target == Bool
        begin
          to_bool(value)
        rescue e : Exception
          puts "ERROR: failed to parse #{key} (value: <<#{value}>>, parse error: #{e})"
          puts "Description: #{options[:description]}" if options[:description]
          puts "Example: #{options[:example]?}" if options[:example]?
          puts "Default: #{options[:default]?}" if options[:default]?
          return terminate_handler!(key)
        end
      elsif target == Int32
        begin
          value.is_a?(String) ? value.to_i : value
        rescue e : Exception
          puts "ERROR: failed to parse #{key} (value: <<#{value}>>, parse error: #{e})"
          puts "Description: #{options[:description]}" if options[:description]
          puts "Example: #{options[:example]?}" if options[:example]?
          puts "Default: #{options[:default]?}" if options[:default]?
          return terminate_handler!(key)
        end
      elsif target == Int64
        begin
          value.is_a?(String) ? value.to_i64 : value
        rescue e : Exception
          puts "ERROR: failed to parse #{key} (value: <<#{value}>>, parse error: #{e})"
          puts "Description: #{options[:description]}" if options[:description]
          puts "Example: #{options[:example]?}" if options[:example]?
          puts "Default: #{options[:default]?}" if options[:default]?
          return terminate_handler!(key)
        end
      elsif target == Float32
        begin
          value.is_a?(String) ? value.to_f32 : value
        rescue e : Exception
          puts "ERROR: failed to parse #{key} (value: <<#{value}>>, parse error: #{e})"
          puts "Description: #{options[:description]}" if options[:description]
          puts "Example: #{options[:example]?}" if options[:example]?
          puts "Default: #{options[:default]?}" if options[:default]?
          return terminate_handler!(key)
        end
      elsif target == Float64
        begin
          value.is_a?(String) ? value.to_f64 : value
        rescue e : Exception
          puts "ERROR: failed to parse #{key} (value: <<#{value}>>, parse error: #{e})"
          puts "Description: #{options[:description]}" if options[:description]
          puts "Example: #{options[:example]?}" if options[:example]?
          puts "Default: #{options[:default]?}" if options[:default]?
          return terminate_handler!(key)
        end
      else
        puts "ERROR: unsupported type detected for environment variable #{key} (got: <<#{value}>>, deduced <<#{value}}>> of type <<#{target}>>)"
        puts "Description: #{options[:description]}" if options[:description]
        puts "Example: #{options[:example]?}" if options[:example]?
        puts "Default: #{options[:default]?}" if options[:default]?
        puts "Hint: if nothing works, try to use a String, and then write your own converter."
        return terminate_handler!(key)
      end

    Log.info { result.is_a?(String) && result.empty? ? "#{key} => (not set)" : "#{key} => #{result}" }
    result
  end

  macro expect_env(name, **options)
    {% if options[:type] %}
      {{name}} = (read_env_variable "{{name}}", {{options.double_splat}}).as({{ options[:type] }})
    {% elsif options[:default].is_a?(NumberLiteral) %}
      {% if options[:default].kind == :i32 %}
        {{name}} = (read_env_variable "{{name}}", {{options.double_splat}}).as(Int32)
      {% elsif options[:default].kind == :i64 %}
        {{name}} = (read_env_variable "{{name}}", {{options.double_splat}}).as(Int64)
      {% elsif options[:default].kind == :f32 %}
        {{name}} = (read_env_variable "{{name}}", {{options.double_splat}}).as(Float32)
      {% elsif options[:default].kind == :f64 %}
        {{name}} = (read_env_variable "{{name}}", {{options.double_splat}}).as(Float64)
      {% else %}
        # TODO: can this be reached?
        throw "Unexpected NumberLiteralType"
      {% end %}
    {% elsif options[:default].is_a?(BoolLiteral) %}
      {{name}} = (read_env_variable "{{name}}", {{options.double_splat}}).as(Bool)
    {% else %}
      {{name}} = (read_env_variable "{{name}}", {{options.double_splat}}).to_s
    {% end %}
  end

  macro config(conf = "config")
    Log.info { "# %s begin" % {{ conf }} }
    {{ yield }}
    Log.info { "# %s end\n" % {{ conf }} }
  end

  # predefined matchers:
  NUMBER = /^[0-9]+$/
  FLAG   = /\A(?:true|false|on|off|1|0|enabled?|disabled?|yes|no)\z/i

  def self.pretty_regexp(regexp : Regex) : String
    case regexp
    when NUMBER
      %Q("#{regexp.source} (a non-negative integer)")
    when FLAG
      %Q("#{regexp.source} (a boolean flag: "true","1","on","enabled","yes" vs "false","0","off","disabled","no"))
    else
      regexp.source
    end
  end

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
