require "cli_builder/version"

module CliBuilder
  require 'cli_builder/menu'
  require 'cli_builder/crud'

  def printInputValidation
    puts "\n****Error: Please enter a valid number****"
    puts "\n"
end

  def user_input_validation
    system "clear" or system "cls"
    printInputValidation
    build_menu
end

  def get_user_input
    user_input = gets.chomp
    user_input == "exit" ? exit : user_input
end

# Need to evaluate logic chian... basically want to execute the appropriate logic based on the user input here. Next step is to evalate whether we want to use build_menu from menu
#  or something else depending on crud vs normal menu vs method
def call_menu_option(menu_option)
  if menu_option.class == CliBuilder::Menu
      menu_option.build_menu
  elsif self.class == CliBuilder::Crud
      Crud.send(menu_option.to_sym)
      build_menu
  else
      send(menu_option)
      build_menu
  end
end

def execute_application_logic(user_input)
    menu_options.each_with_index do |menu_option, index|
        case user_input
        when previous_menu_option
            system "clear" or system "cls"
            parent.build_menu
        when main_menu_option
            system "clear" or system "cls"
            self.class.main_menu.build_menu
        when menu_option_number(index)
            system "clear" or system "cls"
            call_menu_option(menu_option)
        end
    end
end
  # Goal - seperate out CLI interaction logic aka the input and decision making of which class to use to build the menus from the actual building of the menus

end
