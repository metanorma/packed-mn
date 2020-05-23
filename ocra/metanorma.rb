#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'openssl'
require 'open-uri'
require 'net/https'
require 'tempfile'

def determine_cert_path
  return 'cacert.pem.mozilla' if Gem.win_platform?
  #path = '/__enclose_io_memfs__/local/vendor/cacert.pem.mozilla'
  #return path if File.file?(path)
  #File.join('vendor', 'cacert.pem.mozilla')
end

def cert_file_path
  cert_tempfile = Tempfile.new
  cert_tempfile.tap { |n| n.puts(File.read(determine_cert_path)) }.close
  cert_file_path = cert_tempfile.path
end

dl_ext = (RbConfig::CONFIG['host_os'] =~ /darwin/ ? 'bundle' : 'so')
LIBSASS_TEMP_WRAPPER = "libsass.#{dl_ext}"
cert_file_path = nil
DEBUG = ENV['DEBUG']

begin
  # HACK: create temp libsass wrapper in current directory to use with ffi
  #require 'bundler/cli'
  #require 'bundler/cli/common'

  #sassc_path = Bundler::CLI::Common.select_spec('sassc', :regex_match).full_gem_path
  #File
  #  .new(LIBSASS_TEMP_WRAPPER, 'wb')
  #  .puts(File.read(File.join(sassc_path, 'ext', LIBSASS_TEMP_WRAPPER)))

  # Check ssl availability, if not use vendor ssl certificate
  begin
    Net::HTTP.get(URI('https://www.iso.org/'))
  rescue OpenSSL::SSL::SSLError
    puts('Cannot use SSL requests, installing custom certificate') if DEBUG
    Net::HTTP.class_eval do
      alias _use_ssl= use_ssl=

      def use_ssl= boolean
        self.ca_file = cert_file_path
        self.verify_mode = OpenSSL::SSL::VERIFY_PEER
        self._use_ssl = boolean
      end
    end
  end

  # explicitly load all dependent gems
  # ruby packer cannot use gem load path correctly.
  require 'isodoc'
  require 'metanorma-acme'
  require 'metanorma-csand'
  require 'metanorma-csd'
  require 'metanorma-gb'
  require 'metanorma-iec'
  require 'metanorma-ietf'
  require 'metanorma-itu'
  require 'metanorma-m3d'
  require 'metanorma-mpfd'
  require 'metanorma-nist'
  require 'metanorma-ogc'
  require 'metanorma-rsd'
  require 'metanorma-standoc'
  require 'metanorma-unece'
  require 'metanorma'
  require 'nokogiri'
  require 'git'
  require 'metanorma-iso'
  require 'metanorma/cli'
  require 'sassc'
  require 'thor'

  # start up the CLI
  Metanorma::Cli.start(ARGV)
ensure
  # Ensure temp wrapper was deleted
  #FileUtils.rm(LIBSASS_TEMP_WRAPPER)
end
