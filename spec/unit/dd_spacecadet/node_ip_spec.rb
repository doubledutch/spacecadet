require 'spec_helper'

describe DoubleDutch::SpaceCadet::NodeIP do
  let(:env) { 'dfw-test' }

  before do
    client_resp = double('ClientResponse', data: mock_data)

    client = double('Client', list_servers: client_resp)

    client_hash = { 'dfw-test' => client }

    allow(DoubleDutch::SpaceCadet::Config).to receive(:servers_client)
      .and_return(client_hash)
  end

  after { allow(DoubleDutch::SpaceCadet::Config).to receive(:servers_client).and_call_original }

  describe '.get_ip_for' do
    it 'should return the correct IP address for the name' do
      expect(DoubleDutch::SpaceCadet::NodeIP.get_ip_for(env, 'test-app01'))
        .to eql('127.0.0.1')

      expect(DoubleDutch::SpaceCadet::NodeIP.get_ip_for(env, 'test-app02'))
        .to eql('127.0.0.2')
    end
  end

  describe '.get_name_for' do
    it 'should return the correct IP address for the name' do
      expect(DoubleDutch::SpaceCadet::NodeIP.get_name_for(env, '127.0.0.1'))
        .to eql('test-app01')

      expect(DoubleDutch::SpaceCadet::NodeIP.get_name_for(env, '127.0.0.2'))
        .to eql('test-app02')
    end
  end
end

def mock_data
  {
    body: {
      'servers' => [
        {
          'name' => 'test-app01',
          'addresses' => {
            'private' => [
              { 'addr' => '127.0.0.1' }
            ]
          }
        },
        {
          'name' => 'tEst-APP02',
          'addresses' => {
            'private' => [
              { 'addr' => '127.0.0.2' }
            ]
          }
        }
      ]
    }
  }
end
