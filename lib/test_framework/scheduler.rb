# 389-test - testing framework for 389 Directory Server
#
# Copyright (C) 2013 Jan Rusnacko
#
# This file is part of 389-test.
#
# 389-test is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# 389-test is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with 389-test. If not, see <http://www.gnu.org/licenses/>.
#
# For alternative license options, contact the copyright holder.
#
# Jan Rusnacko <rusnackoj@gmail.com>

require 'util/os'

class Scheduler
    include OS

    def initialize(testsuites)
        @testsuites = testsuites
        @sequential_testsuites = Array.new
        @parallel_testsuites = Array.new
        # Testsuite that does not have :parallelizable specified is parallelizable by default
        @testsuites.each do |testsuite|
            if testsuite.get_options[:parallelizable] == :false
                @sequential_testsuites << testsuite
            else
                @parallel_testsuites << testsuite
            end
        end
        @pid_to_testsuite = Hash.new
        @testsuite_to_shared_file = Hash.new
    end

    def run
        number_of_cpus.times do
            schedule_new
        end
        until @pid_to_testsuite.empty?
            pid = Process.wait
            cleanup_finished(pid)
            schedule_new
        end
        # Execute non-parallelizable testsuites in sequence
        @sequential_testsuites.each do |testsuite|
            testsuite.execute
        end
    end

    private

    def schedule_new
        if ! @parallel_testsuites.empty? then
            testsuite_to_run = @parallel_testsuites.pop
            shared_file = get_tmp_file
            @testsuite_to_shared_file[testsuite_to_run.name] = shared_file
            pid = Process.fork do
                testsuite_to_run.execute
                # We are in a different process, so to send results to parent, dump them into shared file
                File.open(shared_file, 'w+') {|file| file.write(testsuite_to_run.store_results)}
            end
            @pid_to_testsuite[pid] = testsuite_to_run
        end
    end

    def cleanup_finished(pid)
        if ! is_process_alive?(pid)
            testsuite = @pid_to_testsuite[pid]
            File.open(@testsuite_to_shared_file[testsuite.name],'r+') {|file| testsuite.load_results(file.read)}
            @pid_to_testsuite.delete(pid)
            File.delete(@testsuite_to_shared_file[testsuite.name])
        end
    end
end