#!/usr/bin/env ruby

require 'pathname'
require 'fileutils'

# add framework to libpath
$:.unshift File.expand_path("../../lib", Pathname.new(__FILE__).realpath)

require 'test_framework/controller'
require 'test_framework/configuration'

config = Configuration.new
controller = Controller.new(config)
controller.execute
controller.write_reports