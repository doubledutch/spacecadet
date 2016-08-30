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

require 'fog'

module DoubleDutch
  module SpaceCadet
    # Class Config is used to configure a client for a specific Rackspace account
    # You provide the `env`, usually for format is <geo>-<env> (e.g., dfw-prod)
    class Config
      @@servers_client = {}
      @@lbs_client = {}

      class << self
        def register(env, username, key, region)
          # init servers_client if it is nil
          @@servers_client[env] ||= Fog::Compute.new(
            provider: 'rackspace',
            rackspace_username: username,
            rackspace_api_key: key,
            rackspace_region: region
          )

          # init lbs_client if it is nil
          @@lbs_client[env] ||= Fog::Rackspace::LoadBalancers.new(
            rackspace_username: username,
            rackspace_api_key: key,
            rackspace_region: region
          )
        end

        # DoubleDutch::SpaceCadet::Config.servers.client
        # returns @@servers_client
        def servers_client
          @@servers_client
        end

        # DoubleDutch::SpaceCadet::Config.lbs.client
        # returns @@lbs_client
        def lbs_client
          @@lbs_client
        end
      end
    end
  end
end
