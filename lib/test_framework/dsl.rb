
require "test_framework/testcase"

PASS = Testcase::PASS
FAIL = Testcase::FAIL
UNKNOWN = Testcase::UNKNOWN

def testsuite(name)
    Testsuite::Builder.name = name
end

def options(options={})
    Testsuite::Builder.options = options
end

def testcases(&block)
    Testsuite::Builder.testcases(&block)
end