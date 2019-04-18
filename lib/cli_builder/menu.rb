# require 'pry'
module CliBuilder

    #TODO: Fix tests and add more tests (4 hours)
    #TODO: Refactor main menu area (2 hours), think about private etc
    #TODO: Build Crud section (8 hours)
    #TODO: Add readme (2 hours)
    #TODO: Add readme (2 hours)
    #TODO: Fix project organization
 

    class Menu
        attr_accessor :title, :menu_options, :parent
        @@all = [];
        @@main_menu = {};
#******************************************Initialize and set key variables*************************************

        def self.all
            @@all
        end

        def self.main_menu
            @@main_menu
        end

        def self.main_menu=(menu)
            @@main_menu = menu
        end

        def assignParents(menu_options)
            menu_options.each do | menu_option | 
                if menu_option.class == CliBuilder::Menu
                    menu_option.parent = self
                end
            end 
        end

        def initialize(title: 'default menu title', menu_options: [])
            #TODO: Review on the usecase... but this may not be necessary
            self.title = title.downcase.gsub(/\s+/,"_").downcase.to_sym
            self.menu_options = menu_options
            assignParents(menu_options)
            Menu.all << self
            Menu.main_menu = self
        end

# **************************************Menu Print and Build Methods********************************************************************
        def build_menu
            self.build_menu_title
            self.build_menu_body
            self.build_application
        end

        def titlecase(string)
            string.split("_").each {|word| word.capitalize!}.join(" ")
        end

        def build_menu_title
            puts "#{titlecase(self.title.to_s)}"
            puts ""
        end

        def build_menu_body
            menu_options.each_with_index do |menu_option, index| 
                if menu_option.class == CliBuilder::Menu
                    puts "#{index + 1}. #{titlecase(menu_option.title.to_s)}"
                else
                    puts "#{index + 1}. #{titlecase(menu_option.to_s)}"
                end
            end
            #Do not add Back options to main menu (last menu created)
            if self != Menu.main_menu
                puts "#{menu_options.length + 1}. Back to Previous Menu"
                puts "#{menu_options.length + 2}. Back to Main Menu"
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
            if !user_input.between?(1, menu_options.length+2)
                user_input_validation
            else
                @@current_menu = self.menu_options[user_input-1]
                execute_application_logic(user_input)
            end
        end

        def execute_application_logic(user_input)
            self.menu_options.each_with_index do |menu_option, index|
                executable_menu_option = index + 1
                previous_menu_option = menu_options.length + 1
                main_menu_option = menu_options.length + 2

                case user_input
                when previous_menu_option
                self.parent.build_menu
                when main_menu_option
                Menu.main_menu.build_menu
                when executable_menu_option
                if menu_option.class == CliBuilder::Menu
                    menu_option.build_menu
                else
                    send(menu_option)
                    self.build_menu
                end
                end
            end
        end

        def user_input_validation
                puts "\n****Error: Please enter a valid number****"
                puts "\n"
                self.build_menu
        end

    end
end


