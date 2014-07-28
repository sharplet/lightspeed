$:.unshift File.expand_path('../lib', __FILE__)
require 'rake/swift'
require 'rake/clean'

Swift.configure do |c|

  c.sdk = :macosx # default value
  # c.sdk = :iphonesimulator # module builds fine, linker error building executable
  # c.sdk = :iphoneos # LOTS of errors

  c.build_dir = 'Build' # default value

end

task :default => :build

desc "Build executable HelloRake and all modules"
task :build => 'bin/hello'

swiftmodule 'Hello'
swiftmodule 'Rake'

directory 'bin'
file 'bin/hello' => ['main.swift', 'bin', 'Hello', 'Rake'] do |t|
  main, _, *modules = *t.sources
  linker_opts = modules.map {|m| "-l#{m}" }
  swift '-o', t.name, *linker_opts, main
end

CLEAN.include('bin')
CLEAN.include('Build')
