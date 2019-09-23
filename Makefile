clean:
	rm ./build/* || true
compile:
	./bin/rubyc -o build/metanorma metanorma_entry_point
build: clean compile