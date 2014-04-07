require 'rake'
require 'cane/rake_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.pattern = File.join(File.dirname(__FILE__), 'spec', '**', '*_spec.rb')
end

Cane::RakeTask.new('quality') do |cane|
  cane.canefile = '.cane'
end

task :all => [:quality, :spec]

task :default => :all
