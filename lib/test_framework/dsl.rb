
def Object.const_missing(const)
	const.to_s
end

def method_missing(method, *args)
	method.to_s
end

def testcase(name)
	TestcaseBuilder.name = name
end

def with(*parameters)
	TestcaseBuilder.add_parameters(parameters)
end

def run(&block)
	TestsuiteBuilder.add_testcase(TestcaseBuilder.create_testcase(&block))
end

def testsuite(name)
	TestsuiteBuilder.name(name)
end