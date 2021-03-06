require 'open_auth2'
require 'spec_helper'

describe OpenAuth2::Token do
  let(:config) do
    OpenAuth2::Config.new do |c|
      c.provider = :facebook
    end
  end

  subject { OpenAuth2::Token.new(config) }

  context '#initialize' do
    it 'accepts config as argument' do
      subject = described_class.new(config)
      subject.config.should == config
    end

    it 'sets @faraday_url' do
      subject.faraday_url.should == 'https://graph.facebook.com'
    end
  end
end
