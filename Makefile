clean:
	rm ./build/* || true
compile:
	./bin/rubyc --clean-tmpdir -o build/metanorma metanorma_entry_point
build: clean compile