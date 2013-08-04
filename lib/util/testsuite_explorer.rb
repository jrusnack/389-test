
module TestsuiteExplorer

    SELECT_ALL = :all
    SELECT_MANUALLY = :select_manually

    def self.get_testsuites_paths(configuration)
        if configuration.testsuites_to_run == nil
            return discover_testsuites(configuration.test_directory)
        else
            all_testsuites = discover_testsuites(configuration.test_directory)
            return filter_testsuites_to_run(all_testsuites, configuration)
        end
    end

    # Returns array of paths of all discovered testsuites
    def self.discover_testsuites(directory)
        testsuites_paths = Array.new
        # loop over all directories containing testsuites
        Dir.glob(directory + "/*") do |testsuite_directory|
            next if testsuite_directory == '.' or testsuite_directory == '..'
            # loop over all files within testsuite directory
            Dir.glob("#{testsuite_directory}/*") do |file|
                next if file == '.' or file == '..'
                # if file contains keyword 'testsuite', add it to the list of testsuites
                if File.readlines(file).grep(/testsuite/).size > 0
                    testsuites_paths << file
                end
            end
        end
        return testsuites_paths
    end

    # Given the array of paths to testsuites, returns array of paths of testsuites
    # that are to be run according to the configuration.testsuites_to_run
    def self.filter_testsuites_to_run(testsuites_paths, configuration)
        testsuites_to_run = Array.new
        testsuites_paths.each do |testsuite_file|
            name = File.readlines(testsuite_file).grep(/testsuite/)[0].gsub(/.*testsuite "(.*)"/,'\1').strip
            testsuites_to_run << testsuite_file if configuration.testsuites_to_run.include?(name)
        end
        return testsuites_to_run
    end

end