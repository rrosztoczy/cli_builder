# CliBuilder

CliBuilder provides tools to help you build CLI menu based applications quickly. The CliBuilder::Menu class gives you the ability to create full menu interfaces and the underlying functionality with a few simple arguments. All you have to do is decide on your menu structure and the methods you would like to run. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cli_builder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cli_builder

## Usage

After installing and requiring the gem, to use CliBuilder::Menu all you need to do is determine your menu tree and write the methods you would like the menus to implement. 

### Create a menu instance

A new "men" is created as by instantiating a new CliBuilder::Menu instance and passing it the menu title as a string and the menu options as an array of symbols. These menu options should either be symbols (that correspond exactly to the names of the method you would like the application to run) or they should be references to other CliBuilder::Menu instances.

For example, imagine you have a one level menu. You would like this menu to be able to run three different methods based on the users selection. The method names are menu_option_method_one, menu_option_method_two, and menu_option_method_three. The menu object would be instantiated as follows:

```ruby
CliBuilder::Menu.new(title: "your title as string", menu_options: [:menu_option_method_one, :menu_option_method_two, :menu_option_method_three])
```

### Nest menus and methods to create a full application

Menu options can be either method names (as symbols) or references to other CliBuilder::Menu instances. When the option is another menu instance, selecting it in the application will bring the user to that menu. Building off of the previous example, here is what a two menu level application would look like:

sub_menu = CliBuilder::Menu.new(title: "This is the Sub Menu", menu_options: [:sub_menu_option_method_one, :sub_menu_option_method_two, :sub_menu_option_method_three])

main_menu = CliBuilder::Menu.new(title: "This is the Main Menu", menu_options: [sub_menu, :main_menu_option_method_one, :main_menu_option_method_two])

When CliBuilder::Menu instances are nested within eachother, the last instance to be declared will be the main menu. This final menu is the menu that the application will be built from.

### Build the application

To build the application, call the build_menu method on the main menu. Continuing with the previous example, to run the application and build the menu out the full code would be:

sub_menu = CliBuilder::Menu.new(title: "This is the Sub Menu", menu_options: [:sub_menu_option_method_one, :sub_menu_option_method_two, :sub_menu_option_method_three])

main_menu = CliBuilder::Menu.new(title: "This is the Main Menu", menu_options: [sub_menu, :main_menu_option_method_one, :main_menu_option_method_two])

main_menu.build_menu

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/<rrosztoczy>/cli_builder.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
