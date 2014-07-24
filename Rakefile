$:.unshift File.expand_path('../lib', __FILE__)
require 'rake/swift'
require 'rake/clean'

task :default => :build

desc "Build executable HelloRake and all modules"
task :build => 'HelloRake'

def source_files_for(lib_or_module)
  dir = lib_or_module.pathmap("%{lib,}n")
  FileList["#{dir}/**/*.swift"]
end

rule '.o' => '.swift' do |t|
  swift '-emit-object', '-o', t.name, t.source, '-module-name', t.source.pathmap("%1d")
end
CLEAN.include('**/*.o')

rule '.dylib' => [->(lib){ source_files_for(lib).ext('.o') }] do |t|
  sh 'swift', '-emit-library', '-o', t.name, *t.sources, '-module-name', t.name.pathmap("%{lib,}n")
end
CLEAN.include('**/*.dylib')

rule '.swiftmodule' => [->(swiftmodule){ source_files_for(swiftmodule) }] do |t|
  swift '-emit-module', '-module-name', t.name.ext, *t.sources
end
CLEAN.include('**/*.swiftmodule')
CLEAN.include('**/*.swiftdoc')

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
