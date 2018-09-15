require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :console do
  require "pry"
  require "./lib/finnegans"
  require "httplog"

  HttpLog.configure do |config|
    # config.log_headers = true
  end

  def reload!
    files = $LOADED_FEATURES.select { |feat| feat =~ %r{lib/finnegans} }
    # Deactivate warning messages.
    original_verbose, $VERBOSE = $VERBOSE, nil
    files.each { |file| load file }
    # Activate warning messages again.
    $VERBOSE = original_verbose
    initial_setup
    "Console reloaded!"
  end

  def initial_setup
    Finnegans.setup do |config|
      config.resources_namespace = ""
    end
  end
  initial_setup

  ARGV.clear
  Pry.start
end
