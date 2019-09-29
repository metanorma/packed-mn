# Metanorma cli compilation

## Compile new version of the executable(just mac os for now)


```bash
$: make build
```

This will clear `build` folder files and compile new version from `metanorma_entry_point` ruby script

## metanorma_entry_point
This script loads all dependencies in order to ruby packer correctly link all gems and their native extensions.


## TODO

Currently, there are 2 forks of `sassc` and `ruby-jing` gems. Sassc was patched in order to load libsass bindings into memfs of executable. Ruby jing fork skips the usage of jing command completely.