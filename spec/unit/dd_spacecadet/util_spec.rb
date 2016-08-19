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
