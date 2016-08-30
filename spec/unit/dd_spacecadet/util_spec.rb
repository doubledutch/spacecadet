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

def mock_lbs_list
  {
    body: {
      'loadBalancers' => [
        {
          'name' => 'test-lb01',
          'id' => 42
        },
        {
          'name' => 'test-lb02',
          'id' => 84
        }
      ]
    }
  }
end

describe DoubleDutch::SpaceCadet::Util do
  let(:env) { 'test-env' }

  before do
    resp = double('Response', data: mock_lbs_list)

    client = double('Fog::Rackspace::LoadBalancers', list_load_balancers: resp)

    allow(DoubleDutch::SpaceCadet::Util).to receive(:_lbs_client).with(env)
      .and_return(client)
  end

  after { allow(DoubleDutch::SpaceCadet::Util).to receive(:_lbs_client).and_call_original }

  describe '.find_lb' do
    it 'should find all load balancers containing the search string' do
      r = DoubleDutch::SpaceCadet::Util.find_lb(env, 'lb')
      expect(r.size).to eql(2)

      expect(r[0][:name]).to eql('test-lb01')
      expect(r[0][:id]).to eql(42)

      expect(r[1][:name]).to eql('test-lb02')
      expect(r[1][:id]).to eql(84)
    end

    it 'should return an empty array for a non-matching value' do
      expect(
        DoubleDutch::SpaceCadet::Util.find_lb(env, 'RANDOM_NOT_FOUND_STRING')
      ).to be_empty
    end
  end
end
