
def testsuite(name, &block)	
	Testsuite::Builder.build(name, &block)
end