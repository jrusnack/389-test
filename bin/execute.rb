#!/usr/bin/env ruby

require 'pathname'
require 'fileutils'

# add framework to libpath
$:.unshift File.expand_path("../../lib", Pathname.new(__FILE__).realpath)

require 'test_framework/controller'
require 'test_framework/configuration'
require 'util/trollop'

# Parse command line arguments
options = Trollop::options do
    opt :parallel, "Run testsuites parallely"
    opt :sequential, "Run testsuites sequentially"
    opt :output_directory, "Directory with output and reports", :type => :string
    opt :junit_report_file, "Name of junit report file", :type => :string
    opt :xml_report_file, "Name of XML report file", :type => :string
    opt :testsuites, "String of comma separated testsuite names", :type => :string
    conflicts :parallel, :sequential
end

# Set configuration according to the passed arguments
config = Configuration.new
config.output_directory = options.output_directory if options.output_directory
config.execution = :parallel if options.parallel
config.execution = :sequential if options.sequential
config.junit_report_file = options.junit_report_file if options.junit_report_file
config.xml_report_file = options.xml_report_file if options.xml_report_file
config.testsuites_to_run = options.testsuites.split(',') if options.testsuites

controller = Controller.new(config)
controller.execute
controller.write_reports