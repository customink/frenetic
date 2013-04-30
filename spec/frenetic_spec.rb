require 'spec_helper'

describe Frenetic do
  let(:test_cfg) do
    {
      url:'http://example.org'
    }
  end

  subject(:instance) { described_class.new( test_cfg ) }

  describe '#connection' do
    subject { instance.connection }

    it { should be_a Faraday::Connection }

    context 'configured with a :username' do
      let(:test_cfg) { super().merge username:'foo' }

      subject { super().builder.handlers }

      it { should include Faraday::Request::BasicAuthentication }
    end

    context 'configured with a :api_token' do
      let(:test_cfg) { super().merge api_token:'API_TOKEN' }

      subject { super().builder.handlers }

      it { should include Faraday::Request::TokenAuthentication }
    end

    context 'configured to use Rack::Cache' do
      let(:test_cfg) { super().merge cache: :rack }

      subject { super().builder.handlers }

      it { should include FaradayMiddleware::RackCompatible }
    end

    context 'when Frenetic is initialized with a block' do
      it 'should yield the Faraday builder to the block argument' do
        builder = nil

        described_class.new(test_cfg) do |b|
          builder = b
        end.connection

        builder.should be_a Faraday::Connection
      end
    end
  end

  describe '#get' do
    subject { instance.get '/foo' }

    it 'should delegate to Faraday' do
      instance.connection.should_receive :get

      subject
    end
  end

  describe '#put' do
    subject { instance.put '/foo' }

    it 'should delegate to Faraday' do
      instance.connection.should_receive :put

      subject
    end
  end

  describe '#post' do
    subject { instance.post '/foo' }

    it 'should delegate to Faraday' do
      instance.connection.should_receive :post

      subject
    end
  end

  describe '#delete' do
    subject { instance.delete '/foo' }

    it 'should delegate to Faraday' do
      instance.connection.should_receive :delete

      subject
    end
  end
end