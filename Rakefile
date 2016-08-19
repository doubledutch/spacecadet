require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'Run RuboCop'
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = %w(-D)
  t.fail_on_error = true
  t.patterns = %w(
    Rakefile Gemfile *.gemspec
    lib/**/*.rb spec/**/*.rb
  )
end

task default: [:rubocop, :spec]
