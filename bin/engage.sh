#!/bin/bash

# Get full path to the directory containing this script
BIN_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Install ruby
$BIN_PATH/check_and_install_ruby.sh &> /dev/null
source ~/.rvm/scripts/rvm

# Execute tests
$BIN_PATH/execute.rb $@