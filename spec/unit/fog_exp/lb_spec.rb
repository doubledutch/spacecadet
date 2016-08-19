require 'spec_helper'

def mock_lbs_summary
  [
    { name: 'test-lb01', id: 42 },
    { name: 'test-lb02', id: 84 }
  ]
end

def mock_lbs_resp
  {
    'loadBalancer' => {
      'name' => 'test-lb01',
      'id' => 42,
      'nodes' => [
        {
          'id' => 142,
          'address' => '10.0.0.142',
          'condition' => 'ENABLED'
        },
        {
          'id' => 184,
          'address' => '10.0.0.184',
          'condition' => 'ENABLED'
        }
      ]
    }
  }
end

def mock_server_data
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

def mock_healthy_status
  [
    {
      name: 'test-lb01',
      id: 42,
      nodes_enabled: 2,
      nodes: [
        {
          name: 'test-app01',
          ip: '10.0.0.142',
          id: 142,
          condition: 'ENABLED'
        },
        {
          name: 'test-app02',
          ip: '10.0.0.142',
          id: 142,
          condition: 'ENABLED'
        }
      ]
    },
    {
      name: 'test-lb02',
      id: 84,
      nodes_enabled: 2,
      nodes: [
        {
          name: 'test-app01',
          ip: '10.0.0.142',
          id: 242,
          condition: 'ENABLED'
        },
        {
          name: 'test-app02',
          ip: '10.0.0.142',
          id: 284,
          condition: 'ENABLED'
        }
      ]
    }
  ]
end

def mock_draining_status
  [
    {
      name: 'test-lb01',
      id: 42,
      nodes_enabled: 1,
      nodes: [
        {
          name: 'test-app01',
          ip: '10.0.0.142',
          id: 142,
          condition: 'ENABLED'
        },
        {
          name: 'test-app02',
          ip: '10.0.0.142',
          id: 142,
          condition: 'DRAINING'
        }
      ]
    },
    {
      name: 'test-lb02',
      id: 84,
      nodes_enabled: 1,
      nodes: [
        {
          name: 'test-app01',
          ip: '10.0.0.142',
          id: 242,
          condition: 'ENABLED'
        },
        {
          name: 'test-app02',
          ip: '10.0.0.142',
          id: 284,
          condition: 'DRAINING'
        }
      ]
    }
  ]
end

describe DoubleDutch::FogExp::LB do
  before do
    allow_any_instance_of(DoubleDutch::FogExp::LB).to receive(:get_lbs).and_return(mock_lbs_summary)
  end
  after do
    allow_any_instance_of(DoubleDutch::FogExp::LB).to receive(:get_lbs).and_call_original
  end

  let(:env) { 'test-env' }
  let(:lb_i) { DoubleDutch::FogExp::LB.new(env) }

  describe '.new' do
    it 'should set the environment and lbs instance variables' do
      i = DoubleDutch::FogExp::LB.new(env)
      expect(i).not_to be_nil
      expect(i.env).to eql('test-env')
      expect(i.lbs).to eql([])
    end
  end

  describe '.find_lb' do
    before do
      allow(DoubleDutch::FogExp::Util).to receive(:_get_lbs).with(env)
        .and_return(mock_lbs_summary)
    end

    after { allow(DoubleDutch::FogExp::Util).to receive(:_get_lbs).and_call_original }

    it 'should find all load balancers containing the search string' do
      r = lb_i.find_lb('lb')
      expect(r.size).to eql(2)

      expect(r[0][:name]).to eql('test-lb01')
      expect(r[0][:id]).to eql(42)

      expect(r[1][:name]).to eql('test-lb02')
      expect(r[1][:id]).to eql(84)
    end

    it 'should return an empty array for a non-matching value' do
      expect(lb_i.find_lb('RANDOM_NOT_FOUND_STRING')).to be_empty
    end
  end

  describe '.find_lb_and_use' do
    before do
      allow(DoubleDutch::FogExp::Util).to receive(:_get_lbs).with(env)
        .and_return(mock_lbs_summary)
    end

    after { allow(DoubleDutch::FogExp::Util).to receive(:_get_lbs).and_call_original }

    it 'should find all load balancers containing the search string and add them' do
      i = DoubleDutch::FogExp::LB.new(env)
      r = i.find_lb_and_use('lb')
      expect(r.size).to eql(2)

      expect(r[0][:name]).to eql('test-lb01')
      expect(r[0][:id]).to eql(42)

      expect(r[1][:name]).to eql('test-lb02')
      expect(r[1][:id]).to eql(84)

      expect(i.lbs.size).to eql(2)
      expect(i.lbs[0]).to eql(r[0][:id])
      expect(i.lbs[1]).to eql(r[1][:id])
    end
  end

  describe '.add_lb' do
    it 'should add the LB ID to the list of LBs' do
      i = DoubleDutch::FogExp::LB.new(env)

      r = i.add_lb(42)
      expect(r.size).to eql(1)
      expect(r[0]).to eql(42)

      r = i.add_lb(84)
      expect(r.size).to eql(2)
      expect(r[0]).to eql(42)
      expect(r[1]).to eql(84)
    end

    it 'should not allow duplicate entries' do
      i = DoubleDutch::FogExp::LB.new(env)

      r = i.add_lb(42)
      expect(r.size).to eql(1)
      expect(r[0]).to eql(42)

      r = i.add_lb(84)
      expect(r.size).to eql(2)
      expect(r[0]).to eql(42)
      expect(r[1]).to eql(84)

      r = i.add_lb(42)
      expect(r.size).to eql(2)
      expect(r[0]).to eql(42)
      expect(r[1]).to eql(84)
    end
  end

  describe '.status' do
    before do
      client_resp = double('ClientResponse', data: mock_server_data)
      client = double('Client', list_servers: client_resp)
      client_hash = { env => client }

      allow(DoubleDutch::FogExp::Config).to receive(:servers_client)
        .and_return(client_hash)

      allow(DoubleDutch::FogExp::NodeIP).to receive(:get_name_for).with(
        env, '10.0.0.142'
      ).and_return('test-app01')

      allow(DoubleDutch::FogExp::NodeIP).to receive(:get_name_for).with(
        env, '10.0.0.184'
      ).and_return('test-app02')

      allow_any_instance_of(DoubleDutch::FogExp::LB).to receive(:get_lb_details)
        .with(42)
        .and_return(mock_lbs_resp)
    end

    after do
      allow(DoubleDutch::FogExp::NodeIP).to receive(:get_name_for).and_call_original
      allow(DoubleDutch::FogExp::NodeIP).to receive(:get_lb_details).and_call_original
      allow(DoubleDutch::FogExp::Config).to receive(:servers_client).and_call_original
      allow_any_instance_of(DoubleDutch::FogExp::LB).to receive(:get_lb_details).and_call_original
    end

    let(:lb_i) do
      i = DoubleDutch::FogExp::LB.new(env)
      expect(i.add_lb(42)).to eql([42])
      i
    end

    it 'should include the name, ID, and enabled nodes count of the load balancer' do
      r = lb_i.status
      expect(r).to be_an(Array)
      expect(r.size).to eql(1)

      expect(r[0][:name]).to eql('test-lb01')
      expect(r[0][:id]).to eql(42)
    end

    it 'should include all backend nodes, their names, and their statuses' do
      r = lb_i.status
      expect(r).to be_an(Array)
      expect(r.size).to eql(1)

      expect(r[0][:nodes]).to be_an(Array)
      expect(r[0][:nodes].size).to eql(2)

      expect(r[0][:nodes][0][:name]).to eql('test-app01')
      expect(r[0][:nodes][0][:id]).to eql(142)
      expect(r[0][:nodes][0][:ip]).to eql('10.0.0.142')
      expect(r[0][:nodes][0][:condition]).to eql('ENABLED')

      expect(r[0][:nodes][1][:name]).to eql('test-app02')
      expect(r[0][:nodes][1][:id]).to eql(184)
      expect(r[0][:nodes][1][:ip]).to eql('10.0.0.184')
      expect(r[0][:nodes][1][:condition]).to eql('ENABLED')
    end
  end

  describe '.update_node' do
    before do
      allow_any_instance_of(DoubleDutch::FogExp::LB).to receive(:status)
        .and_return(mock_healthy_status)
    end

    after do
      allow_any_instance_of(DoubleDutch::FogExp::LB).to receive(:status).and_call_original
    end

    let(:lb_i) do
      i = DoubleDutch::FogExp::LB.new(env)
      expect(i.add_lb(42)).to eql([42])
      expect(i.add_lb(84)).to eql([42, 84])
      i
    end

    context 'input validation' do
      before do
        allow_any_instance_of(DoubleDutch::FogExp::LB).to receive(:flush_updates)
          .and_return(nil)
      end

      after do
        allow_any_instance_of(DoubleDutch::FogExp::LB).to receive(:flush_updates)
          .and_call_original
      end

      it 'should only allow the :draining and :enabled conditions' do
        expect { lb_i.update_node('test-app01', :enabled) }.not_to raise_error
        expect { lb_i.update_node('test-app01', :draining) }.not_to raise_error
        expect { lb_i.update_node('test-app01', :invalid) }.to raise_error(ArgumentError)
      end

      it 'should raise if the node was not found on all LBs' do
        expect { lb_i.update_node('test-app', :enabled) }.to raise_error(RuntimeError)
      end
    end

    context 'when normal' do
      before do
        @lbs_client = double('Fog::Rackspace::LoadBalancers', update_node: nil)
        allow_any_instance_of(DoubleDutch::FogExp::LB).to receive(:lbs_client)
          .and_return(@lbs_client)
      end

      it 'should allow setting the node to drain on all LBs if no others are' do
        expect(@lbs_client).to receive(:update_node)
          .with(42, 142, condition: 'DRAINING').and_return(nil)

        expect(@lbs_client).to receive(:update_node)
          .with(84, 242, condition: 'DRAINING')

        lb_i.update_node('test-app01', :draining)
      end
    end

    context 'when already draining' do
      before do
        allow_any_instance_of(DoubleDutch::FogExp::LB).to receive(:status)
          .and_return(mock_draining_status)
      end

      it 'should actively prevent you from draining multiple backends' do
        expect { lb_i.update_node('test-app01', :draining) }.to raise_error(RuntimeError)
      end
    end
  end
end
