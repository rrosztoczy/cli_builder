require "sinatra"
require "active_record"
require "sinatra/activerecord"
require_relative "./crud.rb"


module CliBuilder
    class Menu
        include Crud
        attr_accessor :title, :menu_options, :parent, :previous_menu_option, :main_menu_option, :menu_type
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

        def menu_options
            @menu_options
        end

        def menu_options=(array)
            @menu_options = array
            self.previous_menu_option = menu_options.length + 1
            self.main_menu_option = menu_options.length + 2
        end



        def initialize(title: 'Default Menu Title', menu_options: [], menu_type: "default")
            self.title = title.downcase.gsub(/\s+/,"_").downcase.to_sym
            self.menu_type = menu_type
            self.menu_options = menu_options         
            assign_parents(menu_options)
            self.previous_menu_option = menu_options.length + 1
            self.main_menu_option = menu_options.length + 2
            self.class.all << self
            # Issue here... crud menus are created on selection not prior so the last one selected will always be main menu...
            self.class.main_menu = self if self.menu_type === "default"
        end

# **************************************Menu Print and Build Methods**********************************************

        def build_menu
            build_menu_title
            build_menu_body
            build_application
        end

        def build_menu_title
            puts "#{Menu.titlecase(title.to_s)}"
            puts ""
        end

        def build_menu_body
            menu_options.each_with_index do |menu_option, index| 
                printMenuOption(menu_option: menu_option, index: index)
            end

            #Do not add Back options to main menu
            if self != self.class.main_menu
                printPreviousMenuOption
                printMainMenuOption
            end
            printPrompt
        end
        

        def build_application
            user_input = get_user_input.to_i
            if !user_input.between?(1, main_menu_option)
                user_input_validation
            else
                execute_application_logic(user_input)
            end
        end

        private
        def self.titlecase(string)
            string.split("_").each {|word| word.capitalize!}.join(" ")
        end

        def self.modelcase(string)
            string.split("_").map {|word| word.capitalize!}.join("").chomp("s")
        end

        def menu_option_number(index)
            index + 1
        end

        def assign_parent(menu_option)
            menu_option.parent = self
        end

        def assign_parents(menu_options)
            menu_options.each do | menu_option | 
                if menu_option.class == self.class
                    assign_parent(menu_option)
                end
            end 
        end

        # Pull into clu_builder ##############
        def get_user_input
            user_input = gets.chomp
            user_input == "exit" ? exit : user_input
        end
        # ######################

        def printPrompt
            puts ""
            puts "Please enter your selection:"
        end

        def printMainMenuOption
            puts "#{main_menu_option}. Back to Main Menu"
        end

        def printPreviousMenuOption
            puts "#{previous_menu_option}. Back to Previous Menu"
        end

        def printMenuTitle(menu_option:, index:)
            puts "#{menu_option_number(index)}. #{Menu.titlecase(menu_option.title.to_s)}"
        end

        def printMethodName(menu_option:, index:)
            puts "#{menu_option_number(index)}. #{Menu.titlecase(menu_option.to_s)}"
        end

        def printInputValidation
            puts "\n****Error: Please enter a valid number****"
            puts "\n"
        end

        def printMenuOption(menu_option:, index:)
            if menu_option.class == self.class
                printMenuTitle(menu_option: menu_option, index: index)
            else
                printMethodName(menu_option: menu_option, index: index)
            end
        end

        def user_input_validation
            system "clear" or system "cls"
            printInputValidation
            build_menu
        end

        # TODO: Pull into CLI Builder
        def call_menu_option(menu_option)
            if menu_option.class == CliBuilder::Menu
                menu_option.build_menu
            # elsif self.class == CliBuilder::Crud
            #     Crud.send(menu_option.to_sym)
            #     build_menu
            # elsif menu_option === :crud_menu
            #     Crud.build_model_menu
            else
                puts "self send is going to is #{self}"
                send(menu_option.to_sym)
                build_menu
            end
        end

        def execute_application_logic(user_input)
            menu_options.each_with_index do |menu_option, index|
                case user_input
                when previous_menu_option
                    puts "why pmo is #{previous_menu_option}"
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

         # ######################
    end

end

    