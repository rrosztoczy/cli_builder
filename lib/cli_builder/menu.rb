# require 'pry'
module CliBuilder

    #TODO: Fix tests and add more tests (4 hours)

    #TODO: Add formatting options(title, layouts?), default formatting clears screen (2 hours)
    #TODO: Add readme (2 hours)
    #TODO: Add readme (2 hours)
    #TODO: Fix project organization

    # April 20th, 2019 To Dos
    #TODO: Refactor main menu area (2 hours)
        # [] SRP Class Refactor: Ask methods as questions of the class
        # [] SRP Method Refactor: Ask what the methods responsibilities are - look for and/or
        # [] Dependency refactor: dependency injection (for class names, class methods and their args), attribute ordering
        # [] Private vs. public
    #TODO: Build Crud section (8 hours)


 
    
    class Menu
        attr_accessor :title, :menu_options, :parent, :previous_menu_option, :main_menu_option
        @@all = [];
        @@main_menu = {};
#******************************************Initialize and set key variables*************************************

        def self.all
            @@all
        end

        # These are potentially private

        def self.main_menu
            @@main_menu
        end

        def self.main_menu=(menu)
            @@main_menu = menu
        end

        def assign_parents(menu_options)
            menu_options.each do | menu_option | 
                if menu_option.class == CliBuilder::Menu
                    menu_option.parent = self
                end
            end 
        end

        # Can I dynamically program a method so that its name is dynamic, 
        # and it takes a send of a menu option and retrieves the actual object
        # I need the name of the object to be a method that retrieves the object. So what about a method that takes a symbol
        # and either gets or sends it?

        def initialize(title: 'Default Menu Title', menu_options: [])
            #TODO: Review on the usecase... but this may not be necessary
            self.title = title.downcase.gsub(/\s+/,"_").downcase.to_sym
            self.menu_options = menu_options         
            assign_parents(menu_options)
            self.previous_menu_option = menu_options.length + 1
            self.main_menu_option = menu_options.length + 2
            Menu.all << self
            Menu.main_menu = self
        end

# **************************************Menu Print and Build Methods********************************************************************

        # Probably private
        def titlecase(string)
            string.split("_").each {|word| word.capitalize!}.join(" ")
        end

        def menu_option_number(index)
            index + 1
        end

        # public
        def build_menu
            build_menu_title
            build_menu_body
            build_application
        end

        def build_menu_title
            puts "#{titlecase(title.to_s)}"
            puts ""
        end

        # Can I reogranize the code to make these the same?
        def printMenuTitle
        end

        def printMethodName
        end

        def printMenuOption(menu_option, index)
            if menu_option.class == CliBuilder::Menu
                puts "#{menu_option_number(index)}. #{titlecase(menu_option.title.to_s)}"
            else
                puts "#{menu_option_number(index)}. #{titlecase(menu_option.to_s)}"
            end
        end

        def build_menu_body
            menu_options.each_with_index do |menu_option, index| 
                printMenuOption(menu_option, index)
            end
            #Do not add Back options to main menu (last menu created)
            if self != Menu.main_menu
                puts "#{previous_menu_option}. Back to Previous Menu"
                puts "#{main_menu_option}. Back to Main Menu"
            end
                puts ""
                puts "Please enter your selection:"
        end

        def get_user_input
            user_input = gets.chomp
            user_input == "exit" ? exit : user_input
        end
        

        def build_application
            user_input = get_user_input.to_i
            if !user_input.between?(1, main_menu_option)
                user_input_validation
            else
                execute_application_logic(user_input)
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
                    Menu.main_menu.build_menu
                when menu_option_number(index)
                    if menu_option.class == CliBuilder::Menu
                        system "clear" or system "cls"
                        menu_option.build_menu
                else
                    system "clear" or system "cls"
                    send(menu_option)
                    build_menu
                end
                end
            end
        end

        def user_input_validation
                puts "\n****Error: Please enter a valid number****"
                puts "\n"
                build_menu
        end

    end
end


