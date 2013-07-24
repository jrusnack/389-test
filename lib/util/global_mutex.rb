
require 'util/os'
require 'fileutils'

class GlobalMutex
	include OS

	def initialize
		@lockfile = get_tmp_file
	end

	def acquire
		sleep (rand(1000) / 1000.0)
		while File.exists?(@lockfile)
			sleep (0.5 + rand(1000)/1000.0)
		end
		FileUtils.touch(@lockfile)
	end

	def release
		File.delete(@lockfile)
	end
end