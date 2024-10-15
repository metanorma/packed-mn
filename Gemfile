# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "iso-639", "<= 0.2.10" # https://github.com/metanorma/packed-mn/issues/26

if Gem.win_platform?
  gem "fontist"
  gem "net-ssh"
  gem "zlib"
end

gem "ffi"
# nokogiry asks for psych >= 4
# psych 5 does not support --enable-bundled-libyaml configuration option
# that is required by tebako
# we set "psych ~> 4" temporarily until
#https://github.com/tamatebako/tebako/issues/93  is fixed
gem "psych", "~> 4"
gem "rake"
gem "sassc"
gem "seven-zip"

group :development do
  gem "byebug"
end

gem "metanorma-cli", "= 1.10.10"
