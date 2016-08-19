require 'dd_spacecadet/config'

module DoubleDutch
  module SpaceCadet
    class Error < StandardError; end
    class ServerNotFound < DoubleDutch::SpaceCadet::Error; end

    # NodeIP is a class of helper methods to find a node
    # based on its name or IP address
    class NodeIP
      # internal data structures
      @@nodes_by_name = {}
      @@nodes_by_ip = {}

      class << self
        # get the IP address for a node
        # based on its label (name)
        def get_ip_for(env, name)
          refresh_nodes(env)

          ip = @@nodes_by_name.dig(env, name)

          raise ServerNotFound, "unable to locate #{name} in #{env} data" if ip.nil?

          ip
        end

        # get the label (name) for a node
        # based on its IP address
        def get_name_for(env, ip)
          refresh_nodes(env)

          name = @@nodes_by_ip.dig(env, ip)

          raise ServerNotFound, "unable to locate #{ip} in #{env} data" if name.nil?

          name
        end

        # clear flushes all cached data
        def clear(env)
          @@nodes_by_name.delete(env)
          @@nodes_by_ip.delete(env)
        end

        private

        # if any of the internal structures are nil or empty
        # we should probably try to do an update
        def needs_refresh?(env)
          (@@nodes_by_name[env].nil? || @@nodes_by_name[env].empty?) ||
            (@@nodes_by_ip[env].nil? || @@nodes_by_ip[env].empty?)
        end

        # this gets the details of the nodes we care about:
        # name and IP
        def get_details(server)
          priv_addresses = server.dig('addresses', 'private')

          raise 'Node missing private addresses' if priv_addresses.nil? || priv_addresses.empty?

          [server['name'].downcase, priv_addresses[0]['addr']]
        end

        # refresh the information we have by pulling down a listing of all
        # nodes from Rackspace
        def refresh_nodes(env)
          # only refresh if a refresh is needed
          if needs_refresh?(env)
            # get an Array of all of the servers
            servers = DoubleDutch::SpaceCadet::Config.servers_client[env].list_servers.data[:body]['servers']

            # hbn: HashByName
            # hbi: HashByIp
            hbn = {}
            hbi = {}

            servers.each do |server|
              name, ip = get_details(server)

              hbn[name] = ip
              hbi[ip] = name
            end

            @@nodes_by_name[env] = hbn
            @@nodes_by_ip[env] = hbi
          end
        end
      end
    end
  end
end
