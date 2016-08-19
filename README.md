# SpaceCadet
SpaceCadet is a library written in Ruby for interacting with the Rackspace Cloud Load Balancers.
The library itself uses the `fog` gem, which is a very popular Ruby library for interacting with
all of the different cloud providers (including Rackspace).

## Why SpaceCadet?
Because this library is meant to speed up deploys, and it's a little "special"...

It's not meant to be pretty, clean, or re-usable. This library was written with one purpose in mind:
being able to change a single backend node from `ENABLED` to `DRAINING` within multiple LBs.

Also: `(Rack)space`.

## Including in Gemfile

```Ruby
gem 'dd_spacecadet', git: 'git@ddgit.me:EngOps/spacecadet.git'
```

## Usage
Here's an example of using the library while interacting with the `DFW` region:

```Ruby
require 'dd_spacecadet'

env = 'dfw-prod'
region = 'DFW'

DoubleDutch::SpaceCadet::Config.register(
  env, ENV['RS_CLOUD_USERNAME'], ENV['RS_CLOUD_KEY'], region
)

dfw_prod = DoubleDutch::SpaceCadet::LB.new(env)

# search for an LB by its label, in this example "stg-lb"
# if multiple LBs match it will use *ALL* of them
dfw_prod.find_lb_and_use('stg-lb')

# gets the status of each LB and its nodes
# you can use dfw.print_status to print the info to stdout with formatting
dfw.status

dfw.update_node('node01', :draining)

dfw.update_node('node01', :enabled)
```
