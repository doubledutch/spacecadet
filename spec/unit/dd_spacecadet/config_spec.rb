require 'spec_helper'

describe DoubleDutch::SpaceCadet::Config do
  before do
    allow(Fog::Compute).to receive(:new)
      .with(
        provider: 'rackspace',
        rackspace_username: 'testUsername',
        rackspace_api_key: 'abc123',
        rackspace_region: 'DFW'
      )
      .and_return(:compute)

    allow(Fog::Rackspace::LoadBalancers).to receive(:new)
      .with(
        rackspace_username: 'testUsername',
        rackspace_api_key: 'abc123',
        rackspace_region: 'DFW'
      )
      .and_return(:loadbalancers)
  end

  after do
    allow(Fog::Compute).to receive(:new).and_call_original
    allow(Fog::Rackspace::LoadBalancers).to receive(:new).and_call_original
  end

  describe '.register' do
    it 'should register without error' do
      expect do
        DoubleDutch::SpaceCadet::Config.register(
          'dfw-test', 'testUsername', 'abc123', 'DFW'
        )
      end.not_to raise_error
    end
  end

  describe '.servers_client' do
    it 'should return the value of @@servers_client' do
      expect(DoubleDutch::SpaceCadet::Config.servers_client['dfw-test2']).to be_nil

      DoubleDutch::SpaceCadet::Config.register(
        'dfw-test2', 'testUsername', 'abc123', 'DFW'
      )

      expect(DoubleDutch::SpaceCadet::Config.servers_client['dfw-test2']).to eql(:compute)
    end
  end

  describe '.lbs_client' do
    it 'should return the value of @@servers_client' do
      expect(DoubleDutch::SpaceCadet::Config.lbs_client['dfw-test3']).to be_nil

      DoubleDutch::SpaceCadet::Config.register(
        'dfw-test3', 'testUsername', 'abc123', 'DFW'
      )

      expect(DoubleDutch::SpaceCadet::Config.lbs_client['dfw-test3']).to eql(:loadbalancers)
    end
  end
end
