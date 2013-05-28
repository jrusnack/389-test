
require "test_framework/controller.rb"

controller = Controller.new
controller.add_testsuite("/home/jrusnack/389-test/testcases/basic")
controller.execute