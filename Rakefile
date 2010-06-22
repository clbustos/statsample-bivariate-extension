#!/usr/bin/ruby
# -*- ruby -*-

require 'rubygems'
require 'spec/rake/spectask'
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
Spec::Rake::SpecTask.new('test_with_rcov') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

# vim: syntax=ruby
