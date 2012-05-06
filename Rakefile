require 'bundler/gem_tasks'
require 'rake/testtask'
require 'yard'
require 'cucumber'
require 'cucumber/rake/task'

task :default => :test

Rake::TestTask.new do |task|
  task.test_files = FileList['test/**/test_*.rb']
  ENV['TESTOPTS'] = '--no-show-detail-immediately --verbose'
end

YARD::Rake::YardocTask.new

Cucumber::Rake::Task.new

namespace :sample do
  desc 'Build the test fixture EPUB'
  task :build do
    input_dir  = 'test/fixtures/book'
    output_dir = 'test/fixtures/'
    FileList["#{input_dir}/**/*"]
    sh "epzip #{input_dir}"
  end
end
