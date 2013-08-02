
module TestsuiteExplorer

    SELECT_ALL = :all
    SELECT_MANUALLY = :select_manually

    def self.get_testsuites_paths(configuration)
        case configuration.selection_method
        when SELECT_ALL
            return discover_testsuites(configuration.test_directory)
        when SELECT_MANUALLY
            #TODO
        else
            raise RuntimeError.new("Unknown testsuite selection method #{configuration.selection_method}.")
        end
    end

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

end