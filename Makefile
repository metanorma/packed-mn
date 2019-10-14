clean:
	[ -d build ] || mkdir build; rm -rf ./build/* || true
prepare_build:
	([ -d project-temp ] || mkdir project-temp) && rm -rf project-temp/* && cp Gemfile* project-temp/ && cp bin/metanorma project-temp/
compile:
	./rubyc --clean-tmpdir --make-args='-j1' -r project-temp/ -o build/metanorma project-temp/metanorma
clean_temp_build:
	rm -rf /tmp/project-temp/
build: clean prepare_build compile clean_temp_build
