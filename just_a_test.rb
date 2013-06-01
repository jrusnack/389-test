
require "test_framework/controller.rb"

controller = Controller.new(".")
controller.add_testsuite("/home/jrusnack/389-test/testcases/basic")
controller.execute("/home/jrusnack/389-test/output")
controller.write_xml_report
controller.write_junit_report