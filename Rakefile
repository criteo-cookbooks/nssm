require 'foodcritic'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)
FoodCritic::Rake::LintTask.new(:foodcritic)

task default: [:foodcritic, :rubocop, :spec]
