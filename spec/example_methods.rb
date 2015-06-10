module ExampleMethods
	# Any method that should be available to examples should be
	# defined in here.
	def fixture_file(f)
		File.expand_path("../fixtures/#{f}", __FILE__)
	end
end
