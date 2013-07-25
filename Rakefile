task default: :console

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r immanence.rb"
end

desc "Run specs"
task :spec do
  require "rspec/core/rake_task"

  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.rspec_opts = %w{--colour --format progress}
  end
end
