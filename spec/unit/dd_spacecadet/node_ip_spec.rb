# Copyright 2016 DoubleDutch, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
