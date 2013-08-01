#!/bin/bash

# Download and install RVM
curl -L https://get.rvm.io | bash
source ~/.rvm/scripts/rvm

# Download, compile and install Ruby 1.9.3
rvm install ruby-1.9.3