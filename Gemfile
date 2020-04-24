# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

github_ref = ENV['GITHUB_REF']
tag_ref_prefix = 'refs/tags/v'
mn_cli_version = if github_ref&.start_with? tag_ref_prefix
  "= #{github_ref.gsub(/^#{tag_ref_prefix}/, '')}"
else
  '~> 1.2'
end

gem 'iso-639', '0.2.10'
gem 'metanorma-cli', mn_cli_version
gem 'metanorma'
gem 'metanorma-acme'
gem 'metanorma-csand'
gem 'metanorma-csd'
gem 'metanorma-gb'
gem 'metanorma-iec'
gem 'metanorma-ietf'
gem 'metanorma-itu'
gem 'metanorma-m3d'
gem 'metanorma-mpfd'
gem 'metanorma-nist'
gem 'metanorma-ogc'
gem 'metanorma-rsd'
gem 'metanorma-standoc'
gem 'metanorma-unece'
gem 'ruby-jing',
    git: 'https://github.com/metanorma/ruby-jing.git',
    ref: 'c28d0204766b502c2239799d2e2605c6d7d7778e'
gem 'sassc',
    git: 'https://github.com/metanorma/sassc-ruby.git',
    ref: 'ce6c3a65b29247476ea1cf1c0f53cf7d5fe46827' # 6e07d9634af0372006e8a5ea62bb80855cb69cb5 - old one

group :development do
  gem 'byebug'
  gem 'rubocop'
end
