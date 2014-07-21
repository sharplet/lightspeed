$:.unshift File.expand_path('../lib', __FILE__)
require "rake/swift"
require "rake/clean"

task :default => :build

task :build => "HelloRake"

file "HelloRake" => "HelloRake.swift" do |t|
  swift t.source
end
CLEAN.include("HelloRake")
