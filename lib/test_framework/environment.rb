
module Environment

	def self.check_environment(configuration)
		# make sure output directory exists
		unless File.exist?(configuration.output_directory)
			raise RuntimeError.new("Configuration.output_directory \"#{configuration.output_directory}\" does not exist")
		end
		# make sure test directory exists
		unless File.exist?(configuration.test_directory)
			raise RuntimeError.new("Configuration.test_directory \"#{configuration.test_directory}\" does not exist")
		end

	end

	def self.prepare(configuration)
		# create output directory if it does not exist
		FileUtils.mkdir_p(configuration.output_directory) unless File.exist?(configuration.output_directory)
	end
end