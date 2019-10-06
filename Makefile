clean:
	[ -d build ] || mkdir build; rm -rf ./build/* || true
compile:
	./rubyc --clean-tmpdir -o build/metanorma metanorma_entry_point
build: clean compile