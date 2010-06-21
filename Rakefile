#!/usr/bin/ruby
# -*- ruby -*-

require 'rubygems'
require 'hoe'

$:.unshift(File.dirname(__FILE__)+"/lib")

require 'statsample/bivariate/extension_version.rb'
Hoe.spec 'statsample-bivariate-extension' do
  self.rubyforge_name = 'ruby-statsample'
  self.version=Statsample::Bivariate::EXTENSION_VERSION
  self.developer('Claudio Bustos', 'clbustos_at_gmail.com')
  self.extra_deps << ["statsample","~>0.13.0"]
  
end

# vim: syntax=ruby
