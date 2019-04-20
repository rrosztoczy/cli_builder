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
        # [X] Dependency refactor: dependency injection (for [X] class names, [X] class methods and their args), [X]attribute ordering
        # [X] Private vs. public
    #TODO: Build Crud section (8 hours)
    #TODO: Formatting options (3 hours)
        # [] Make sure clear, method results and menu options print out is okay.. do not think it is
        # [] Make placement etc. flexible so they can add titles, adjust placement whatever they want


 
    
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

        def initialize(title: 'Default Menu Title', menu_options: [])
            #TODO: Review on the usecase... but this may not be necessary
            self.title = title.downcase.gsub(/\s+/,"_").downcase.to_sym
            self.menu_options = menu_options         
            assign_parents(menu_options)
            self.previous_menu_option = menu_options.length + 1
            self.main_menu_option = menu_options.length + 2
            self.class.all << self
            self.class.main_menu = self
        end

# **************************************Menu Print and Build Methods********************************************************************

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
    def titlecase(string)
        string.split("_").each {|word| word.capitalize!}.join(" ")
    end

    def menu_option_number(index)
        index + 1
    end

    def assign_parents(menu_options)
        menu_options.each do | menu_option | 
            if menu_option.class == self.class
                menu_option.parent = self
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

    def printMenuOption(menu_option:, index:)
        if menu_option.class == self.class
            puts "#{menu_option_number(index)}. #{titlecase(menu_option.title.to_s)}"
        else
            puts "#{menu_option_number(index)}. #{titlecase(menu_option.to_s)}"
        end
    end

    def user_input_validation
        system "clear" or system "cls"
        puts "\n****Error: Please enter a valid number****"
        puts "\n"
        build_menu
end

# Come back to this after crud to see if you can make an improved send
        # Can I reogranize the code to make these the same?
        # def printMenuTitle
        # end

        # def printMethodName
        # end

        # Can I dynamically program a method so that its name is dynamic, 
        # and it takes a send of a menu option and retrieves the actual object
        # I need the name of the object to be a method that retrieves the object. So what about a method that takes a symbol
        # and either gets or sends it?
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


  #********************************************************CRUD Class***********************************************************************
#   The goal of this will be to allow CRUD on table rows from the menu... can I do it based on values dynamically like below or is that
#   Too much? If that is too much... can I do it for just full on table row items based on the table name?
#   class CRUD
#     def self.table_values_menu
#         # This should retrive the unique values from the table
#         table_values = [];

#         # Dynamically define a method for each unique table_value

#         table_values.each_with_index do |table_value, index|
#             define_method :"{table_value}" do
#                 puts "hehe"
#             end
#         end
#     end
#   end
  
  
  
#   What do I mean by crud? Read - Can I search and print a list of somethings based on values?
#   Can I Create, Edit, and Delete based on the same?
#   I could possibly create a menu that brought up all these values, and then when I went to one have another menu where I can crud it..
#   Is that helpful or useful? If I take out create... can maybe more easily edit/delete them...
  
#   class Ex_CRUD
#     def self.ride_by_type_menu
#       ride_type_array = ["UberX & lyft", "UberXL & lyft_plus", "Black & lyft_lux", "Black SUV & lyft_luxsuv", "UberPool & lyft_line"]
    
#       #Dynamically defines methods for the application builder using the product types
#       ride_type_array.each_with_index do |mapped_product_type, index|
#         define_method :"#{mapped_product_type}" do
    
#           #breaks apart product types to access appropriate db values
#           uber = mapped_product_type.split(" & ")[0]
#           lyft = mapped_product_type.split(" & ")[1]
#           uber_rides_arr = Ride.where(product_type: "#{uber}")
#           lyft_rides_arr = Ride.where(product_type: "#{lyft}")
    
#           #formats and puts out ride data
#           puts "Ride prices by product type:"
#           puts "\n"
#           rides_arr = (uber_rides_arr + lyft_rides_arr).sort_by {|ride| ride.name}
#           rides_arr.each do |ride|
#             puts "#{ride.name.ljust(40)} #{ride.product_type.ljust(12)} avg $#{ride.avg_estimate.to_s.ljust(12)} est #{ride.estimate.ljust(12)} #{ride.created_at}"
#           end
#           puts "\n"
#           ride_menu
#         end
#       end
    
#       #Builds dynamic application menu and functionality from product definitions
#       application_builder("Find Ride Data by Type", ride_type_array)
#   #   end
#   end
# end
end


