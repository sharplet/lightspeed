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

end

task :default => :build

desc "Build executable hello and all modules"
task :build => 'bin/hello'

swiftmodule 'Hello'
swiftmodule 'Rake'

directory 'bin'
file 'bin/hello' => ['main.swift', 'bin', 'Hello', 'Rake'] do |t|
  main, _, *modules = *t.sources
  linker_opts = modules.map {|m| "-l#{m}" }
  swift '-o', t.name, *linker_opts, main
end

CLOBBER.include('bin')
CLOBBER.include('pkg')
CLOBBER.include('Build/Products')
CLEAN.include('Build/Intermediates')
