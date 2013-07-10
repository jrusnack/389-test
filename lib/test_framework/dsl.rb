
require "test_framework/testcase"

PASS = Testcase::PASS
FAIL = Testcase::FAIL
UNKNOWN = Testcase::UNKNOWN

def testsuite(name, &block)	
	Testsuite::Builder.init(name, &block)
end
