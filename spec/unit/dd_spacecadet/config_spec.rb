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
