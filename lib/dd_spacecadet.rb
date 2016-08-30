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

require 'dd_spacecadet/version'
require 'dd_spacecadet/util'
require 'dd_spacecadet/error'
require 'dd_spacecadet/config'
require 'dd_spacecadet/node_ip'
require 'dd_spacecadet/lb'

# DoubleDutch is the top-level module for
# internal DoubleDutch modules and classes
module DoubleDutch
  # SpaceCadet is a module for configuring the Rackspace Cloud Load Balancers
  module SpaceCadet; end
end
