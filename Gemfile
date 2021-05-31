# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "iso-639", "<= 0.2.10" # https://github.com/metanorma/packed-mn/issues/26

gem "metanorma-mpfa"
gem "metanorma-ribose"

# ruby-packer need to be rebuild with rubygems.pkg.github.com certs
# source "https://rubygems.pkg.github.com/metanorma" do
gem "metanorma-bsi"
gem "metanorma-nist"
# end

gem "fontist" if Gem.win_platform?

gem "ffi"
gem "rake"
gem "seven_zip_ruby"

group :development do
  gem "byebug"
end

gem "metanorma-cli", "= 1.4.9"
