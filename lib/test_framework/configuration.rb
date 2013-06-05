
require 'util/testsuite_explorer'

class Configuration

	def initialize
		####################################################################################
		# These are default values of options used when no specific value is set manually

		@root_directory 	= File.expand_path("../../../", Pathname.new(__FILE__).realpath)
		@output_directory	= "#{@root_directory}/output"
		@test_directory 	= "#{@root_directory}/test"

		@selection_method 	= TestsuiteExplorer::SELECT_ALL
		####################################################################################

		# Defined getters and setters for all instance variables
		instance_variables.each do |variable|
			variable = variable[1..-1]
			instance_eval("def #{variable};@#{variable};end")
			instance_eval("def #{variable}=(value);@#{variable}=value;end")
		end
	end
end