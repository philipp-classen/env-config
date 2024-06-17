require "./spec_helper"

old_foo = ENV["FOO"]?
ENV["FOO"] = nil

class ConfigDefaultVar < EnvConfig
  expect_env FOO, description: "Test variable", default: "foo"
end

ENV["FOO"] = old_foo

describe ConfigDefaultVar do
  it "works" do
    ConfigDefaultVar::FOO.should eq("foo")
  end
end

######################################################################

old_foo = ENV["FOO"]?
old_bar = ENV["BAR"]?
ENV["FOO"] = "foo_from_env"
ENV["BAR"] = "bar_from_env"

class ConfigFromEnv < EnvConfig
  expect_env FOO, description: "Test variable", default: "foo"
  expect_env BAR, description: "Test variable"
end

ENV["FOO"] = old_foo
ENV["BAR"] = old_bar

describe ConfigFromEnv do
  it "works" do
    ConfigFromEnv::FOO.should eq("foo_from_env")
    ConfigFromEnv::BAR.should eq("bar_from_env")
  end
end

######################################################################

old_foo = ENV["FOO"]?
ENV["FOO"] = nil

class ConfigMissing < EnvConfig
  @@missing_key = ""

  def self.terminate_handler!(key) : Nil
    @@missing_key = key
  end

  def self.missing_key
    @@missing_key
  end

  expect_env FOO, description: "This will fail, since it is not set"
end

ENV["FOO"] = old_foo

describe ConfigMissing do
  it "works" do
    ConfigMissing.missing_key.should eq("FOO")
    ConfigMissing::FOO # that it not optimized away
  end
end

######################################################################

old_foo = ENV["FOO"]?
old_bar = ENV["BAR"]?
ENV["FOO"] = "foo_from_env"
ENV["BAR"] = "bar_from_env"

class ConfigWithBlock < EnvConfig
  config do
    expect_env FOO, description: "Test variable"
    expect_env BAR, description: "Test variable"
  end
end

ENV["FOO"] = old_foo
ENV["BAR"] = old_bar

describe ConfigWithBlock do
  it "works" do
    ConfigWithBlock::FOO.should eq("foo_from_env")
    ConfigWithBlock::BAR.should eq("bar_from_env")
  end
end

######################################################################

old_foo = ENV["FOO"]?
old_bar = ENV["BAR"]?
ENV["FOO"] = "foo_from_env"
ENV["BAR"] = "bar_from_env"

class ConfigWithNamedBlock < EnvConfig
  config("database") do
    expect_env FOO, description: "Test variable"
  end

  config("logging") do
    expect_env BAR, description: "Test variable"
  end
end

ENV["FOO"] = old_foo
ENV["BAR"] = old_bar

describe ConfigWithNamedBlock do
  it "works" do
    ConfigWithNamedBlock::FOO.should eq("foo_from_env")
    ConfigWithNamedBlock::BAR.should eq("bar_from_env")
  end
end

######################################################################

old_foo = ENV["FOO"]?
old_bar = ENV["BAR"]?
ENV["FOO"] = "42"
ENV["BAR"] = "2024-06-14"

class ConfigWithRegexp < EnvConfig
  config do
    expect_env FOO, description: "Integer", type: Int32, regexp: NUMBER
    expect_env BAR, description: "YYYY-MM-DD", regexp: /^\d{4}-\d{2}-\d{2}$/
  end
end

ENV["FOO"] = old_foo
ENV["BAR"] = old_bar

describe ConfigWithRegexp do
  it "works" do
    ConfigWithRegexp::FOO.should eq(42)
    ConfigWithRegexp::BAR.should eq("2024-06-14")
  end
end

######################################################################

old_foo = ENV["FOO"]?
old_bar = ENV["BAR"]?
ENV["FOO"] = nil
ENV["BAR"] = nil

class ConfigWithFlagDefault < EnvConfig
  config do
    expect_env FOO, description: "Bool", default: true
    expect_env BAR, description: "Bool", default: false
  end
end

ENV["FOO"] = old_foo
ENV["BAR"] = old_bar

describe ConfigWithFlagDefault do
  it "works" do
    ConfigWithFlagDefault::FOO.should eq(true)
    ConfigWithFlagDefault::BAR.should eq(false)
  end
end

######################################################################

old_foo = ENV["FOO"]?
old_bar = ENV["BAR"]?
ENV["FOO"] = "true"
ENV["BAR"] = "false"

class ConfigWithFlagEnv < EnvConfig
  config do
    expect_env FOO, description: "Bool", type: Bool
    expect_env BAR, description: "Bool", type: Bool
  end
end

ENV["FOO"] = old_foo
ENV["BAR"] = old_bar

describe ConfigWithFlagEnv do
  it "works" do
    ConfigWithFlagEnv::FOO.should eq(true)
    ConfigWithFlagEnv::BAR.should eq(false)
  end
end

######################################################################

old_foo = ENV["FOO"]?
ENV["FOO"] = nil

class ConfigWithInt64Default < EnvConfig
  config do
    expect_env FOO, description: "Int64 to be detected by default", default: 4000000000_i64
  end
end

ENV["FOO"] = old_foo

describe ConfigWithInt64Default do
  it "works" do
    ConfigWithInt64Default::FOO.should eq(4000000000_i64)
  end
end

######################################################################

old_foo = ENV["FOO"]?
ENV["FOO"] = "5000000000"

class ConfigWithInt64Env < EnvConfig
  config do
    expect_env FOO, description: "Int64 to be detected by type", type: Int64
  end
end

ENV["FOO"] = old_foo

describe ConfigWithInt64Env do
  it "works" do
    ConfigWithInt64Env::FOO.should eq(5000000000_i64)
  end
end

######################################################################

old_foo = ENV["FOO"]?
ENV["FOO"] = "3.14"

class ConfigWithFloat32Env < EnvConfig
  config do
    expect_env FOO, description: "Float32 to be detected by type", type: Float32
  end
end

ENV["FOO"] = old_foo

describe ConfigWithFloat32Env do
  it "works" do
    ConfigWithFloat32Env::FOO.should eq(3.14_f32)
    ConfigWithFloat32Env::FOO.class.should eq(Float32)
  end
end

######################################################################

old_foo = ENV["FOO"]?
ENV["FOO"] = "3.14"

class ConfigWithFloat64Env < EnvConfig
  config do
    expect_env FOO, description: "Float64 to be detected by type", type: Float64
  end
end

ENV["FOO"] = old_foo

describe ConfigWithFloat64Env do
  it "works" do
    ConfigWithFloat64Env::FOO.should eq(3.14_f64)
    ConfigWithFloat64Env::FOO.class.should eq(Float64)
  end
end

######################################################################

old_foo = ENV["FOO"]?
ENV["FOO"] = nil

class ConfigWithFloat32Default < EnvConfig
  config do
    expect_env FOO, description: "Float32 to be detected by default", default: 3.14_f32
  end
end

ENV["FOO"] = old_foo

describe ConfigWithFloat32Env do
  it "works" do
    ConfigWithFloat32Env::FOO.should eq(3.14_f32)
    ConfigWithFloat32Env::FOO.class.should eq(Float32)
  end
end

######################################################################

old_foo = ENV["FOO"]?
ENV["FOO"] = nil

class ConfigWithFloat64Default < EnvConfig
  config do
    expect_env FOO, description: "Float64 to be detected by default", default: 3.14_f64
  end
end

ENV["FOO"] = old_foo

describe ConfigWithFloat64Env do
  it "works" do
    ConfigWithFloat64Env::FOO.should eq(3.14_f64)
    ConfigWithFloat64Env::FOO.class.should eq(Float64)
  end
end