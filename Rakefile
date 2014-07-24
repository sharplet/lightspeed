$:.unshift File.expand_path('../lib', __FILE__)
require 'rake/swift'
require 'rake/clean'

task :default => :build

desc "Build executable HelloRake and all modules"
task :build => 'HelloRake'

MODULES = FileList['Hello', 'Rake']
MODULES.each do |mod|
  swiftmodule(mod)
end

file 'HelloRake' => ['main.swift', *MODULES] do |t|
  module_opts = ['-I.']
  linker_opts = ['-L.'] + MODULES.pathmap("-l%n")
  swift '-o', t.name, t.source, *module_opts, *linker_opts
end

CLEAN.include('HelloRake')
CLEAN.include('**/*.o')
CLEAN.include('**/*.dylib')
CLEAN.include('**/*.swiftmodule')
CLEAN.include('**/*.swiftdoc')
