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

require 'dd_spacecadet/error'
require 'dd_spacecadet/util'

module DoubleDutch
  module SpaceCadet
    # LB is the class used for manging the Load Balancer configs
    class LB
      MAX_IMMUTABLE_RETRIES ||= 3

      attr_reader :env, :lbs

      def initialize(env)
        @env = env
        @lbs = []
      end

      # reset the class (clear the added LBs)
      def reset
        @lbs.clear
      end

      # add an LB, by ID, to be managed by this class
      def add_lb(lb_id)
        @lbs = (@lbs << lb_id).uniq
      end

      # find an LB using a search string
      def find_lb(search)
        DoubleDutch::SpaceCadet::Util.find_lb(@env, search)
      end

      # the same as find_lb, but it adds each to the classs
      def find_lb_and_use(search)
        find_lb(search).each { |lb| add_lb(lb[:id]) }
      end

      # gets the status of managed LBs
      def status
        details = @lbs.map { |lb_id| get_lb_details(lb_id) }

        parse_lb_details(details)
      end

      # updates the condition of a node with the Load Balancer
      # this is used to move from :enabled => :draining
      def update_node(name, condition)
        # check whether the condition is valid
        unless [:enabled, :draining].include?(condition)
          raise ArgumentError, 'Invalid condition (can be :enabled or :draining)'
        end

        lb_details = status

        raise LoadBalancerNotFound, 'No LB details found!' if lb_details.empty?

        to_update = calculate_update(name.downcase, lb_details, condition)

        if to_update.size != lb_details.size
          raise LBInconsistentState, "We only found #{to_update.size} nodes across #{lb_details.size} LBs"
        end

        flush_updates(to_update)
      end

      # this does the same thing as status
      # put it prints it the information to stdout
      def render_status
        status.each do |st|
          puts "#{st[:name]} (#{st[:id]})"
          st[:nodes].each { |n| puts "    #{n[:name]}    #{n[:condition]}    #{n[:id]}    #{n[:ip]}" }
          puts '---'
        end

        nil
      end

      private

      def lbs_client
        DoubleDutch::SpaceCadet::Config.lbs_client[@env]
      end

      def get_lb_details(lb_id)
        lbs_client.get_load_balancer(lb_id).data[:body]
      end

      def flush_updates(to_update)
        to_update.each do |update|
          flush_update(update)
        end
      end

      # safety check before taking actions
      # this makes sure we cannot set more than one node to draining
      def safe?(lbd, condition)
        # if it's a draining operation
        # check for safety
        if condition == :draining
          # this inverts the result of the boolean statement
          # if these conditions are met, we are *NOT* safe
          # if there is onle one mode enabled: NOT SAFE
          # if any node is disabled/draining: NOT SAFE
          return !(lbd[:nodes_enabled] == 1 || lbd[:nodes_enabled] != lbd[:nodes].size)
        end

        # otherwise, it's safe
        true
      end

      # calculate which node IDs need to be updated
      def calculate_update(name, details, condition)
        to_update = []

        # loop over the individual load balancers
        details.each do |lbd|
          # make sure this LB is in a safe state to mutate
          unless safe?(lbd, condition)
            raise LBUnsafe, "#{lbd[:name]} LB unsafe for draining"
          end

          # loop over the registered nodes to find the ID
          # of the one we want to update the condition of
          lbd[:nodes].each do |lbn|
            to_update << { lb_id: lbd[:id], node_id: lbn[:id], condition: condition } if lbn[:name] == name
          end
        end

        to_update
      end

      def flush_update(update)
        count = 0

        loop do
          begin
            call_update(update)

            break
          # immediately after updating an LB config, Rackspace marks the LB
          # as being immutable (meaning no further config changes can happen)
          # this exception below is what is thrown by Fog if we hit that situation
          rescue Fog::Rackspace::LoadBalancers::ServiceError
            raise if count == (MAX_IMMUTABLE_RETRIES - 1)

            sleep(5)

            count += 1
          end
        end
      end

      def call_update(update)
        lbs_client.update_node(
          update[:lb_id],
          update[:node_id],
          condition: update[:condition].to_s.upcase
        )
      end

      def parse_lb_details(details)
        details.map do |lb|
          detail = {
            name: lb['loadBalancer']['name'].downcase,
            id: lb['loadBalancer']['id']
          }

          detail[:nodes], detail[:nodes_enabled] = parse_nodes(lb['loadBalancer']['nodes'])

          detail
        end
      end

      def parse_nodes(nodes)
        enabled_count = 0

        n = nodes.map do |node|
          enabled_count += 1 if node['condition'].casecmp('enabled').zero?

          {
            name: DoubleDutch::SpaceCadet::NodeIP.get_name_for(@env, node['address']),
            ip: node['address'],
            id: node['id'],
            condition: node['condition']
          }
        end

        [n.sort { |x, y| x[:name] <=> y[:name] }, enabled_count]
      end
    end
  end
end
