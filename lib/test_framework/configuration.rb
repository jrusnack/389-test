
require 'util/testsuite_explorer'

class Configuration

	def initialize
		####################################################################################
		# These are default values of options used when no specific value is set manually

		# Directories
		@root_directory 	= File.expand_path("../../../", Pathname.new(__FILE__).realpath)
		@output_directory	= "#{@root_directory}/output/#{Time.now.strftime("%Y.%m.%d-%H:%M")}"
		@test_directory 	= "#{@root_directory}/test"

		# Run all testsuites by default
		@selection_method 	= TestsuiteExplorer::SELECT_ALL

		# Reports
		@write_xml_report 	= true
		@write_junit_report = true
		@xml_report_file	= @output_directory + "/results.xml"
		@junit_report_file	= @output_directory + "/junit.xml"

		# Execute multiple testsuites concurrently by default
		@execution = :parallel
		# @execution = :sequential

		####################################################################################

		# Defined getters and setters for all instance variables
		instance_variables.each do |variable|
			variable = variable[1..-1]
			instance_eval("def #{variable};@#{variable};end")
			instance_eval("def #{variable}=(value);@#{variable}=value;end")
		end
	end
end