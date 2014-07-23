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

rule '.swiftmodule' => [->(swiftmodule){ source_files_for(swiftmodule) }] do |t|
  swift '-emit-module', '-module-name', t.name.ext, *t.sources
end

MODULES = FileList['Hello'].ext('.swiftmodule')
CLEAN.include(MODULES)
CLEAN.include(MODULES.ext('.swiftdoc'))

LIBS = MODULES.ext('.dylib').pathmap("lib%f")
CLEAN.include(LIBS)

file 'HelloRake' => ['main.swift', LIBS, MODULES] do |t|
  libs = FileList.new(t.sources.select {|d| d.end_with? ".dylib" })
  lib_opts = libs.pathmap("%{lib,}n").ext.map {|l| "-l#{l}" }
  swift '-o', t.name, '-I.', '-L.', *lib_opts, t.source
end
CLEAN.include('HelloRake')
