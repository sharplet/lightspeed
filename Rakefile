lib = File.expand_path('../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)
require 'lightspeed'
require 'rake/clean'

namespace :gem do
  require 'bundler/gem_tasks'
end

Lightspeed.configure do |c|

  c.sdk = :macosx # default value
  # c.sdk = :iphonesimulator # module builds fine, linker error building executable
  # c.sdk = :iphoneos # LOTS of errors

  c.build_dir = 'Build' # default value

  c.executables_dir = 'bin' # default value

end

task :default => :build_all

desc "Build all targets"
task :build_all => 'hello'

swiftmodule 'Hello'
swiftmodule 'Rake'

swiftapp 'hello' => ['Hello', 'Rake'] do |app|
  app.source_files = 'main.swift'
end

CLOBBER.include('bin')
CLOBBER.include('pkg')
CLOBBER.include('Build/Products')
CLEAN.include('Build/Intermediates')
