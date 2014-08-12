lib = File.expand_path('../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)
require 'lightspeed'
require 'rake/clean'

task :default => :build_all

desc "Build all targets"
task :build_all => ['lspd', 'hello']

namespace :gem do
  require 'bundler/gem_tasks'
end

CLEAN.include('bin')
CLEAN.include('pkg')
CLEAN.include('Build')
