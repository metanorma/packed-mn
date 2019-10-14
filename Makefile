clean:
	[ -d build ] || mkdir build; rm -rf ./build/* || true
prepare_build:
	([ -d /tmp/project-temp ] || mkdir /tmp/project-temp) && rm -rf /tmp/project-temp/* && cp Gemfile* /tmp/project-temp/ && cp bin/metanorma /tmp/project-temp/
compile:
	./rubyc --clean-tmpdir --make-args='-j1' -r /tmp/project-temp/ -o build/metanorma /tmp/project-temp/metanorma
clean_temp_build:
	rm -rf /tmp/project-temp/
build: clean prepare_build compile clean_temp_build
