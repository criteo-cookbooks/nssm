class NSSM
  module ParameterHelper
    # Cleanup string read from nssm dump
    def strip_and_unescape(value)
      value.strip
           .gsub(/^\^"(.*)\^"$/, '\1')
           .gsub(/^"(.*)"$/, '\1')
           .gsub(/\^([\\"&%^<>|])/, '\1')
           .gsub(/\\\\/, '\\')
    end
    # Cleanup string that'll be set as nssm parameter
    def prepare_parameter(value)
      value.to_s
           .strip
           .gsub('"', '\"')
    end
  end
end