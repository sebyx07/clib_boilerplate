# frozen_string_literal: true

require 'rake/clean'
require 'yaml'
require 'fileutils'

# Load and parse .clib.yml
begin
  config = YAML.load_file('.clib.yml')
rescue => e
  puts "Error loading .clib.yml: #{e.message}"
  config = {}
end

# Determine platform and architecture
PLATFORM = case RUBY_PLATFORM
           when /linux/   then 'linux'
           when /darwin/  then 'darwin'
           when /mswin|mingw/ then 'windows'
           else 'unknown'
           end

ARCH = case RUBY_PLATFORM
       when /x86_64|amd64/ then 'x86_64'
       when /i386|x86/ then 'x86'
       when /arm64|aarch64/ then 'arm64'
       else 'unknown'
       end

# Merge platform-specific settings
platform_config = config.dig('platforms', PLATFORM) || {}
compiler_config = (config['compiler'] || {}).merge(platform_config)
test_config = config['test'] || {}

# Set up compilation variables
CC = ENV['CC'] || compiler_config['cc'] || 'gcc'
BASE_CFLAGS = [compiler_config['cflags']].flatten.compact
CFLAGS = ENV['CFLAGS']&.split || BASE_CFLAGS

# Set up linker variables
BASE_LDFLAGS = [compiler_config['ldflags']].flatten.compact
LDFLAGS = ENV['LDFLAGS']&.split || BASE_LDFLAGS

# Test flags
TEST_CFLAGS = [test_config['cflags']].flatten.compact

# Library name and paths
LIB_NAME = config['name'] || 'hello-world'
LIB_VERSION = config['version'] || '0.1.0'

# Platform-specific library extension
LIB_EXT = case PLATFORM
          when 'linux' then '.so'
          when 'darwin' then '.dylib'
          when 'windows' then '.dll'
          else '.so'
          end

# Build directories structure
BUILD_DIR = 'build'
BUILD_LIB_DIR = "#{BUILD_DIR}/lib"
BUILD_TEST_DIR = "#{BUILD_DIR}/test"
BUILD_OBJ_DIR = "#{BUILD_DIR}/obj"

# Create build directories
directory BUILD_DIR
directory BUILD_LIB_DIR
directory BUILD_TEST_DIR
directory BUILD_OBJ_DIR

# Clean task configuration
CLEAN.include("#{BUILD_DIR}/**/*")
CLOBBER.include(BUILD_DIR)

namespace :compile do
  desc 'Compile the C library'
  task lib: BUILD_LIB_DIR do
    lib_file = "#{BUILD_LIB_DIR}/lib#{LIB_NAME}#{LIB_EXT}"
    source_files = FileList['ext/src/*.c'].map(&:to_s).join(' ')

    compile_cmd = "#{CC} #{CFLAGS.join(' ')} #{LDFLAGS.join(' ')} -o #{lib_file} #{source_files}"

    puts 'Compiling library...'
    puts compile_cmd if ENV['VERBOSE']
    system compile_cmd
  end

  desc 'Compile tests'
  task tests: BUILD_TEST_DIR do
    test_files = FileList['test/*_test.c']
    test_files.each do |test_file|
      test_name = File.basename(test_file, '.c')
      test_bin = "#{BUILD_TEST_DIR}/#{test_name}#{PLATFORM == 'windows' ? '.exe' : ''}"

      source_files = FileList['ext/src/*.c'].map(&:to_s).join(' ')
      compile_cmd = "#{CC} #{CFLAGS.join(' ')} #{TEST_CFLAGS.join(' ')} -I./ext/src -o #{test_bin} #{test_file} #{source_files}"

      puts "Compiling test: #{test_name}"
      puts compile_cmd if ENV['VERBOSE']
      system compile_cmd
    end
  end
end

desc 'Run tests'
task :run_tests do
  test_bins = FileList["#{BUILD_TEST_DIR}/*"]
  failed_tests = []

  test_bins.each do |test_bin|
    puts "\nRunning test: #{File.basename(test_bin)}"
    system(test_bin.to_s) or failed_tests << test_bin
  end

  # Report results
  puts "\nTest Results:"
  puts "#{test_bins.size} tests run, #{failed_tests.size} failures"
  unless failed_tests.empty?
    puts "Failed tests:"
    failed_tests.each { |test| puts "  - #{File.basename(test)}" }
    exit 1
  end
end

task test: ['compile:tests', :run_tests]

desc 'Print build configuration'
task :config do
  puts 'Build Configuration:'
  puts "  Platform: #{PLATFORM}"
  puts "  Architecture: #{ARCH}"
  puts "  Compiler: #{CC}"
  puts "  CFLAGS: #{CFLAGS.join(' ')}"
  puts "  LDFLAGS: #{LDFLAGS.join(' ')}"
  puts "  Test CFLAGS: #{TEST_CFLAGS.join(' ')}"
  puts "  Library Name: #{LIB_NAME}"
  puts "  Library Version: #{LIB_VERSION}"
  puts "  Library Extension: #{LIB_EXT}"
  puts "  Build Directory: #{BUILD_DIR}"
end

task default: [:config, 'compile:lib', :test]