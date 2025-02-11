# CLIb Boilerplate 🛠️

A powerful boilerplate for building and distributing C libraries as Ruby gems. This template provides everything you need to create production-ready C libraries that can be easily distributed through RubyGems.

## Quick Start 🚀

1. Use this template:
```bash
git clone https://github.com/sebyx07/clib_boilerplate your_gem_name
cd your_gem_name
rm -rf .git
git init
```

2. Update library configuration in `.clib.yml`:
```yaml
name: your-gem-name
version: 0.1.0
compiler:
  cc: gcc
  cflags: -Wall -Wextra -O2
dependencies:
  other-clib-lib: "~> 1.0"  # Optional: Add CLIb dependencies
```

3. Write your C library code in `ext/src/`
4. Write your tests in `test/`
5. Build and test:
```bash
rake
```

## Why CLIb? 🤔

- Automatic cross-platform compilation settings
- Simple YAML configuration
- Built-in test framework for C code
- Seamless RubyGems integration
- Easy dependency management between C libraries

## Directory Structure 📁

```
your-gem-name/
  ├── build/           # Build artifacts
  │   ├── lib/        # Compiled libraries
  │   ├── obj/        # Object files
  │   └── test/       # Test binaries
  ├── ext/
  │   └── src/        # Your C library source files
  ├── test/           # C test files
  ├── .gitignore
  ├── Gemfile
  ├── Rakefile
  ├── your-gem-name.gemspec
  └── .clib.yml
```

## Creating Your C Library 💻

1. Add your C library files to `ext/src/`:
```c
// ext/src/your_lib.h
#ifndef YOUR_LIB_H
#define YOUR_LIB_H

int your_function(void);

#endif

// ext/src/your_lib.c
#include "your_lib.h"

int your_function(void) {
    return 42;
}
```

2. Add tests in `test/`:
```c
// test/your_lib_test.c
#include <assert.h>
#include "your_lib.h"

int main() {
    assert(your_function() == 42);
    return 0;
}
```

## Build Commands 🔧

```bash
rake              # Full build and test
rake clean        # Clean build artifacts
rake clobber     # Remove build directory
rake test        # Run tests
rake config      # Show build configuration
rake gem:build   # Build the gem package
rake gem:publish # Publish gem to RubyGems
VERBOSE=1 rake   # Show compilation commands
```

## Configuration ⚙️

The `.clib.yml` file controls your library build:

```yaml
name: your-gem-name
version: 0.1.0
compiler:
  cc: gcc
  cflags: -Wall -Wextra -O2
  ldflags:
dependencies:
  other-clib-lib: "~> 1.0"  # Optional CLIb dependencies
test:
  cflags: -Wall -Wextra
platforms:
  linux:
    cflags: -fPIC
    ldflags: -shared
  darwin:
    cflags: -fPIC
    ldflags: -dynamiclib
  windows:
    cc: cl
    cflags: /W4
    ldflags: /DLL
```

## Dependencies 📦

CLIb makes it easy to use other CLIb libraries as dependencies:
1.Declare dependencies in `.clib.yml`:
```yaml
dependencies:
  clib-useful: "~> 1.0"    # Major version 1, minor updates ok
  clib-other: ">= 2.1"     # Version 2.1 or higher
```

2. Use dependency headers in your code:
```c
#include "clib-useful/useful.h"        // From clib-useful
#include "clib-other/other_lib.h"     // From clib-other

void my_function(void) {
    useful_function();     // Use function from dependency
    other_function();      // Use another dependency
}
```

CLIb automatically:
- Finds and loads dependencies
- Sets up include paths for headers
- Links against dependency libraries
- Handles recursive dependencies

Check your dependency configuration:
```bash
rake config   # Shows all dependency paths and versions
```

## Your Gemspec 💎

```ruby
# your-gem-name.gemspec
require 'yaml'

config = YAML.load_file(File.join(__dir__, '.clib.yml'))

Gem::Specification.new do |spec|
  spec.name          = config['name']
  spec.version       = config['version']
  spec.authors       = ['Your Name']
  spec.email         = ['your.email@example.com']
  spec.summary       = 'Your C library wrapped as a Ruby gem'
  spec.description   = 'Detailed description of your C library'
  spec.homepage      = 'https://github.com/yourusername/your-gem-name'
  spec.license       = 'MIT'

  spec.files         = Dir['{ext,include}/**/*', 'LICENSE', 'README.md']
  spec.required_ruby_version = '>= 3.0'

  # Dependencies from .clib.yml are automatically handled
  if config['dependencies']
    config['dependencies'].each do |lib, version|
      spec.add_runtime_dependency lib, version
    end
  end

  spec.add_development_dependency 'rake', '~> 13.0'
end
```

## Environment Variables 🌍

- `CC`: Override compiler selection
- `CFLAGS`: Additional compiler flags
- `LDFLAGS`: Additional linker flags
- `VERBOSE`: Show compilation commands

## Example Usage in Ruby 💎

After installing your gem:

```ruby
require 'your_gem_name'

# Use your C library functions
result = YourGemName.your_function
puts result  # => 42
```

## Testing 🧪

CLIb automatically builds and runs your tests:

1. Write tests in C using assert:
```c
// test/feature_test.c
#include <assert.h>
#include "your_lib.h"

int main() {
    // Test your functions
    assert(your_function() == 42);
    return 0;
}
```

2. Run tests:
```bash
rake test
```

Tests automatically include your library and its dependencies.

## Contributing 🤝

1. Fork the clib_boilerplate repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License 📄

This boilerplate is available as open source under the terms of the MIT License.

## Credits 🙏

Created by @sebyx07