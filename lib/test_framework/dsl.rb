
def Object.const_missing(const)
	const.to_s
end

def method_missing(method, *args)
	method.to_s
end

def testsuite(name, &block)
	Testsuite::Builder.build(name, &block)
end