# frozen_string_literal: true

require 'rake/clean'
require 'yaml'
require 'fileutils'
require 'rubygems'
CLIB_CONFIG = YAML.load_file('.clib.yml')

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

# Process CLIb dependencies
def process_dependencies
  return {} unless CLIB_CONFIG['dependencies']

  deps = {}
  CLIB_CONFIG['dependencies'].each do |dep_name, version|
    gem_spec = Gem::Specification.find_by_name(dep_name)
    dep_config = YAML.load_file(File.join(gem_spec.gem_dir, '.clib.yml'))

    deps[dep_name] = {
      include_path: File.join(gem_spec.gem_dir, 'ext/src'),
      lib_path: File.join(gem_spec.gem_dir, 'lib', dep_name),
      lib_name: dep_config['name'],
      version: version
    }
  rescue Gem::MissingSpecError
    puts "Warning: Dependency #{dep_name} (#{version}) not found"
  end
  deps
end

DEPENDENCIES = process_dependencies

# Merge platform-specific settings
platform_config = CLIB_CONFIG.dig('platforms', PLATFORM) || {}
compiler_config = (CLIB_CONFIG['compiler'] || {}).merge(platform_config)
test_config = CLIB_CONFIG['test'] || {}

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
LIB_NAME = CLIB_CONFIG['name']
LIB_VERSION = CLIB_CONFIG['version'] || '0.1.0'

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

# Helper to generate dependency flags
def dependency_flags
  return ['', ''] if DEPENDENCIES.empty?

  include_flags = DEPENDENCIES.values.map { |d| "-I#{d[:include_path]}" }.join(' ')
  lib_flags = DEPENDENCIES.values.map do |d|
    [
      "-L#{d[:lib_path]}",
      "-l#{d[:lib_name]}"
    ].join(' ')
  end.join(' ')

  [include_flags, lib_flags]
end

namespace :compile do
  desc 'Compile the C library'
  task lib: BUILD_LIB_DIR do
    lib_file = "#{BUILD_LIB_DIR}/lib#{LIB_NAME}#{LIB_EXT}"
    source_files = FileList['ext/src/*.c'].map(&:to_s).join(' ')

    include_flags, lib_flags = dependency_flags

    compile_cmd = [
      CC,
      include_flags,
      CFLAGS.join(' '),
      LDFLAGS.join(' '),
      lib_flags,
      "-o #{lib_file}",
      source_files
    ].compact.join(' ')

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
      include_flags, lib_flags = dependency_flags

      compile_cmd = [
        CC,
        include_flags,
        '-I./ext/src',
        CFLAGS.join(' '),
        TEST_CFLAGS.join(' '),
        lib_flags,
        "-o #{test_bin}",
        test_file,
        source_files
      ].compact.join(' ')

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
    puts 'Failed tests:'
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

  unless DEPENDENCIES.empty?
    puts "\nDependencies:"
    DEPENDENCIES.each do |name, info|
      puts "  #{name} (#{info[:version]}):"
      puts "    Include Path: #{info[:include_path]}"
      puts "    Library Path: #{info[:lib_path]}"
    end
  end
end

namespace :gem do
  desc 'Build gem and move to build directory'
  task :build do
    # Build the gem
    system "gem build #{LIB_NAME}.gemspec"

    # Move to build directory
    gem_file = "#{LIB_NAME}-#{LIB_VERSION}.gem"
    if File.exist?(gem_file)
      FileUtils.mv(gem_file, "#{BUILD_DIR}/#{gem_file}")
      puts "Moved #{gem_file} to #{BUILD_DIR}/"
    else
      puts 'Error: Failed to build gem'
      exit 1
    end
  end

  desc 'Publish gem to RubyGems'
  task :publish do
    gem_file = FileList["#{BUILD_DIR}/#{LIB_NAME}-*.gem"].first
    if gem_file
      puts "Publishing #{gem_file} to RubyGems..."
      system "gem push #{gem_file}"
    else
      puts "No .gem file found in #{BUILD_DIR}/. Run 'rake gem:build' first"
      exit 1
    end
  end
end

# Add gem files to clean task
CLEAN.include("#{BUILD_DIR}/*.gem")

task default: [:config, 'compile:lib', :test]
