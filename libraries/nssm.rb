# Provide NSSM helper methods
module NSSM
  extend ::Chef::Mixin::ShellOut

  module_function

  # Properly format a NSSM command
  def command(binary, action, service, param = nil, sub_param = nil)
    [
      prepare_parameter(binary),
      action, # simple keyword does not need transformation
      prepare_parameter(service),
      prepare_parameter(param),
      prepare_parameter(sub_param, false) # last param does no need quoting
    ].reject(&:empty?).join ' '
  end

  # Cleanup string read from nssm dump
  def strip_and_unescape(value)
    value.strip
         .gsub(/^\^"(.*)\^"$/, '\1')
         .gsub(/^"(.*)"$/, '\1')
         .gsub(/\^([\\"&%^<>|])/, '\1')
         .gsub(/\\\\/, '\\')
  end

  # Cleanup string that'll be set as nssm parameter
  # Optionnally add quotes around given value if necessary
  def prepare_parameter(value, quote = true)
    result = value.to_s.dup.strip.gsub('"', '\"')
    if quote && result =~ /[ *]/
      value.gsub(/^(.*)$/, "\"#{result}\"")
    else
      result
    end
  end
end
