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
