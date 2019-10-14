clean:
	[ -d build ] || mkdir build; rm -rf ./build/* || true
compile:
	./rubyc --clean-tmpdir -o build/metanorma bin/metanorma
build: clean compile