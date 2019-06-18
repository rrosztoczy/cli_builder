
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cli_builder/version"

Gem::Specification.new do |spec|
  spec.name          = "cli_builder"
  spec.version       = CliBuilder::VERSION
  spec.authors       = ["<rrosztoczy>"]
  spec.email         = ["<rrosztoczy@gmail.com>"]

  spec.summary       = %q{cli_builder facilitates the easy creation and use of Command Line Interface applications using Ruby and sqlite3. Welcome to Ruby on Training Rails.}
  spec.description   = %q{cli_builder facilitates the creation and use of Command Line Interface applications in Ruby. It extends simple menu creation and application interface functionality so you can
    easily create new CLI menu interfaces on the fly. It also extends functionality using ruby on top of active record to make dynamically building user data CRUD applications and methods for the CLI simple. 
    Spend time coding the fun and important pieces of your application and let cli_builder do the rest for you. Welcome to Ruby on Training Rails.}
  spec.homepage      = "https://github.com/rrosztoczy/cli_builder"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/rrosztoczy/clibuilder"
    spec.metadata["changelog_uri"] = "https://github.com/rrosztoczy/clibuilder"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra-activerecord", "~> 2.0.13"
  spec.add_development_dependency "bundler", "~> 1.17.3"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
