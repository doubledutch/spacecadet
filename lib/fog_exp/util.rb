require 'fog_exp/config'

module DoubleDutch
  module FogExp
    # Util is a grouping of utility/helper methods
    module Util
      def self._lbs_client(env)
        DoubleDutch::FogExp::Config.lbs_client[env]
      end

      # method for finding an LB based on its name
      def self.find_lb(env, search)
        lookup = search.downcase
        _get_lbs(env).select { |lb| lb[:name].include?(lookup) }
      end

      # get the LBs from Rackspace and parse them to the
      # information we care about: Name & ID
      def self._get_lbs(env)
        _lbs_client(env).list_load_balancers.data[:body]['loadBalancers'].map do |lb|
          {
            name: lb['name'].downcase,
            id: lb['id']
          }
        end
      end
    end
  end
end
