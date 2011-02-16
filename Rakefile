require "bundler"
require "rake/testtask"
require "yard"
Bundler::GemHelper.install_tasks

Rake::TestTask.new do |t|
  t.test_files = FileList["test/test*.rb"]
end

YARD::Rake::YardocTask.new do |t|
  t.files = %w[ lib/fire_poll.rb ]
end

task :default => :test
