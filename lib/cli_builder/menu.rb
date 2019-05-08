require "sinatra"
require "active_record"
require "sinatra/activerecord"

module CliBuilder
    # TODO: [X] - Organize files appropriately
    # TODO: [] - Review tests and test organization
    # TODO: [X] - Write readme
    # TODO: [] - Get code review

    class Menu < ActiveRecord::Base
        # If -- include CRUD, then extend Crud Module
        attr_accessor :title, :menu_options, :parent, :previous_menu_option, :main_menu_option
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

        def initialize(title: 'Default Menu Title', menu_options: [])
            self.title = title.downcase.gsub(/\s+/,"_").downcase.to_sym
            self.menu_options = menu_options         
            assign_parents(menu_options)
            self.previous_menu_option = menu_options.length + 1
            self.main_menu_option = menu_options.length + 2
            self.class.all << self
            self.class.main_menu = self
        end

# **************************************Menu Print and Build Methods**********************************************

        def build_menu
            build_menu_title
            build_menu_body
            build_application
        end

        def build_menu_title
            puts "#{titlecase(title.to_s)}"
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

        def get_user_input
            user_input = gets.chomp
            user_input == "exit" ? exit : user_input
        end

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
            puts "#{menu_option_number(index)}. #{titlecase(menu_option.title.to_s)}"
        end

        def printMethodName(menu_option:, index:)
            puts "#{menu_option_number(index)}. #{titlecase(menu_option.to_s)}"
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

        def call_menu_option(menu_option)
            if menu_option.class == self.class
                menu_option.build_menu
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
    end
           

    ###Include CRUD class
    class Crud < CliBuilder::Menu

        # TODO: for each model do...
        # [] - Build menu of model name with menu options view, create, update, delete
        #       To do this, I actually need to build out the menus in reverse order I believe lol... which is kind of a bitch... would be nicer 
        #       If each menu item was actually a method firing that queried active record and then build a menu... woop!
        #       So... need the model name menus to be methods (yay dynamic method naming..)
        #       Step one... how do I pull all of the model names into an array?
            @@tables =  ActiveRecord::Base.connection.tables.select {|table| table != "schema_migrations" && table != "ar_internal_metadata"}
            @@tables_as_titles = @@tables.map{ |table| titlecase(table)}
            def self.get_tables
                puts @@tables
                puts @@tables_as_titles
            end
            #     ride_type_array = ["UberX & lyft", "UberXL & lyft_plus",
            # def self.write_table_menus
            # ride_type_array.each_with_index do |mapped_product_type, index|
            # #       define_method :"#{mapped_product_type}" do
            # end
        
        
        # [] - View, update delete are each menus that lead to another menu: this one is all, or by table header 
        # [] - All leads to a menu where menu options are all recrods in that table, others lead to menu with only those options
        # [] - From there, the ids trigger either a where, update, or destroy method on taht record
        # [] - That method will be denamically named as the record id, so that entering it triggers it
            
        end
end

#We could make this more extensible by mapping product types in the db and building the array from the db...
# def self.ride_by_type_menu
#     ride_type_array = ["UberX & lyft", "UberXL & lyft_plus", "Black & lyft_lux", "Black SUV & lyft_luxsuv", "UberPool & lyft_line"]
  
#     #Dynamically defines methods for the application builder using the product types
#     ride_type_array.each_with_index do |mapped_product_type, index|
#       define_method :"#{mapped_product_type}" do
  
#         #breaks apart product types to access appropriate db values
#         uber = mapped_product_type.split(" & ")[0]
#         lyft = mapped_product_type.split(" & ")[1]
#         uber_rides_arr = Ride.where(product_type: "#{uber}")
#         lyft_rides_arr = Ride.where(product_type: "#{lyft}")
  
#         #formats and puts out ride data
#         puts "Ride prices by product type:"
#         puts "\n"
#         rides_arr = (uber_rides_arr + lyft_rides_arr).sort_by {|ride| ride.name}
#         rides_arr.each do |ride|
#           puts "#{ride.name.ljust(40)} #{ride.product_type.ljust(12)} avg $#{ride.avg_estimate.to_s.ljust(12)} est #{ride.estimate.ljust(12)} #{ride.created_at}"
#         end
#         puts "\n"
#         ride_menu
#       end
#     end
  
#     #Builds dynamic application menu and functionality from product definitions
#     application_builder("Find Ride Data by Type", ride_type_array)
#   end
  


