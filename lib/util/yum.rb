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
require 'util/string'
require 'util/os'

module Yum
    YUM_REPOS_D="/etc/yum.repos.d"

    @@repo_id_to_file = Hash.new

    def enable_repo(repo_id)
        `sudo yum-config-manager --enable #{repo_id}`
        if ! $?.success? then
            raise RuntimeError.new("Failed to enable repository #{repo_id}. Return code: #{$?.exitstatus}")
        end
    end

    def disable_repo(repo_id)
        `sudo yum-config-manager --disable #{repo_id}`
        if ! $?.success? then
            raise RuntimeError.new("Failed to disable repository #{repo_id}. Return code: #{$?.exitstatus}")
        end
    end

    # Adds new yum repository. Creates a new tmp file in /etc/yum.repos.d
    def add_repo(repo_url)
        repo_id = repo_url.gsub(/http.?:\/\/([a-zA-Z]*)\..*/,'\1')
        repofile = "#{YUM_REPOS_D}/#{repo_id}.repo"
        repo = <<-EOF
            [#{repo_id}]
            name=#{repo_id}
            baseurl=#{repo_url}
            enabled=1
            gpgcheck=0
        EOF
        `sudo touch #{repofile}`
        if ! $?.success? then
            raise RuntimeError.new("Failed to create new tmp repo #{repofile} at /etc/yum.repos.d. Return code: #{$?.exitstatus}")
        end
        `sudo chmod 666 #{repofile}`
        if ! $?.success? then
            raise RuntimeError.new("Failed change permissions on #{repofile} at /etc/yum.repos.d. Return code: #{$?.exitstatus}")
        end
        @@repo_id_to_file[repo_id] = repofile
        `echo \"#{repo.strip_lines}\" >> #{repofile}`
        if ! $?.success? then
            raise RuntimeError.new("Failed to populate repofile ##{repofile} with repo_id #{repo_id} and url #{repo_url}. Return code: #{$?.exitstatus}")
        end
    end

    # Removes repofile from /etc/yum.repos.d
    # Works only on repositories previously added using add_repo(repo_url) method
    def remove_repo(repo_url)
        repo_id = repo_url.gsub(/http.?:\/\/([a-zA-Z]*)\..*/,'\1')
        `sudo rm #{@@repo_id_to_file[repo_id]}`
        if ! $?.success? then
            raise RuntimeError.new("Failed to remove repofile #{repo_id_to_file[repo_id]}. Return code: #{$?.exitstatus}")
        end
    end

    # Return array of enabled repo IDs
    def get_enabled_repos
        output = `yum repolist all`.lines.grep(/enabled/).map {|e| e.gsub(/([^\s]*).*/,'\1').strip}
        if ! $?.success? then
            raise RuntimeError.new("Failed to \'yum repolist all\'. Return code: #{$?.exitstatus}")
        end
        return output
    end

    # Return array of disabled repo IDs
    def get_disabled_repos
        output = `yum repolist all`.lines.grep(/disabled/).map {|e| e.gsub(/([^\s]*).*/,'\1').strip}
        if ! $?.success? then
            raise RuntimeError.new("Failed to \'yum repolist all\'. Return code: #{$?.exitstatus}")
        end
        return output
    end

    # Return array of all repo IDs
    def get_repos
        output=`yum repolist all`.lines.grep(/enabled|disabled/).map {|e| e.gsub(/([^\s]*).*/,'\1').strip}
        if ! $?.success? then
            raise RuntimeError.new("Failed to \'yum repolist all\'. Return code: #{$?.exitstatus}")
        end
        return output
    end

    # Installs package
    def install(package)
        output = `sudo yum -y install #{package} 2>&1`
        if ! $?.success? then
            raise RuntimeError.new("Failed to install #{package}. Return code: #{$?.exitstatus}")
        end
        return output
    end

    # Removes package
    def remove(package)
        output = `sudo yum -y remove #{package} 2>&1`
        if ! $?.success? then
            raise RuntimeError.new("Failed to remove #{package}. Return code: #{$?.exitstatus}")
        end
        return output
    end

    # Returns true iff package is present in repositories and available to install
    def package_available?(package)
        `yum list #{package}`
        if $?.success? then
            return true
        else
            return false
        end
    end

    module_function :enable_repo, :disable_repo, :add_repo, :remove_repo, :get_enabled_repos, \
        :get_disabled_repos, :get_repos, :install, :remove, :package_available?
end