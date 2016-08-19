$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'dd_spacecadet/version'

Gem::Specification.new do |s|
  s.name                  = 'dd_spacecadet'
  s.summary               = 'Library for manipulating Rackspace Cloud Load Balancers'
  s.author                = 'DoubleDutch Engineering Operations'
  s.email                 = 'engops@doubledutch.me'
  s.license               = 'All Rights Reserved'
  s.version               = DoubleDutch::SpaceCadet::VERSION
  s.required_ruby_version = '~> 2.3'
  s.date                  = Time.now.strftime('%Y-%m-%d')
  s.homepage              = ''
  s.description           = ''

  s.test_files            = `git ls-files spec/*`.split
  s.files                 = `git ls-files`.split

  s.add_development_dependency 'rake', '~> 11.2.2'
  s.add_development_dependency 'rspec', '~> 3.5.0'
  s.add_development_dependency 'rubocop', '~> 0.42.0'
  s.add_development_dependency 'irbtools', '~> 2.0.1'

  s.add_runtime_dependency 'fog', '~> 1.38.0'
end
