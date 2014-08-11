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
task :build_all => ['lspd']

swiftapp 'lspd' do |lspd|
  lspd.source_files = 'lspd/main.swift'
end
task 'bin/lspd' => 'Hello.framework'

swiftmodule 'Rake'

framework 'Hello' do |f|
  f.source_files = 'Hello/**/*.{h,c,swift}'
end

swiftmodule 'Greetable' => ['Hello', 'Rake']

swiftapp 'hello' => 'Greetable' do |app|
  app.source_files = 'main.swift'
end

CLEAN.include('bin')
CLEAN.include('pkg')
CLEAN.include('Build')
