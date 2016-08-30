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

$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'dd_spacecadet/version'

Gem::Specification.new do |s|
  s.name                  = 'dd_spacecadet'
  s.summary               = 'Library for manipulating Rackspace Cloud Load Balancers'
  s.author                = 'DoubleDutch Engineering Operations'
  s.email                 = 'engops@doubledutch.me'
  s.license               = 'Apache 2.0'
  s.version               = DoubleDutch::SpaceCadet::VERSION
  s.required_ruby_version = '~> 2.3'
  s.date                  = Time.now.strftime('%Y-%m-%d')
  s.homepage              = 'https://github.com/DoubleDutch/spacecadet'
  s.description           = 'Rubygem for safely managing Rackspace Cloud Load Balancer backend servers'

  s.test_files            = `git ls-files spec/*`.split
  s.files                 = `git ls-files`.split

  s.add_development_dependency 'rake', '~> 11.2.2'
  s.add_development_dependency 'rspec', '~> 3.5.0'
  s.add_development_dependency 'rubocop', '~> 0.42.0'
  s.add_development_dependency 'irbtools', '~> 2.0.1'

  s.add_runtime_dependency 'fog', '~> 1.38.0'
end
