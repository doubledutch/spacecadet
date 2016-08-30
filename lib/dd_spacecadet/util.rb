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

require 'dd_spacecadet/config'

module DoubleDutch
  module SpaceCadet
    # Util is a grouping of utility/helper methods
    module Util
      def self._lbs_client(env)
        DoubleDutch::SpaceCadet::Config.lbs_client[env]
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
