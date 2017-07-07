# frozen_string_literal: true

require 'serverspec_helper'

describe 'selenium::server' do
  describe host('localhost') do
    it { should be_reachable.with(port: 4444) }
  end
end
