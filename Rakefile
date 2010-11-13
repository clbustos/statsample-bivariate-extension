#!/usr/bin/ruby
# -*- ruby -*-

require 'rubygems'
require 'rspec'
require 'rspec/core/rake_task'
require 'hoe'

Hoe.plugin :git

$:.unshift(File.dirname(__FILE__)+"/lib")

require 'statsample/bivariate/extension_version.rb'
Hoe.spec 'statsample-bivariate-extension' do
  self.rubyforge_name = 'ruby-statsample'
  self.version=Statsample::Bivariate::EXTENSION_VERSION
  self.developer('Claudio Bustos', 'clbustos_at_gmail.com')
end



desc "Run all spec with RCov"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
  #t.rcov = true
  #t.rcov_opts = ['--exclude', 'spec']

end

# vim: syntax=ruby
