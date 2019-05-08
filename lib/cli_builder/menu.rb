require "sinatra"
require "active_record"
require "sinatra/activerecord"

module CliBuilder
    # TODO: [X] - Organize files appropriately
    # TODO: [] - Review tests and test organization
    # TODO: [X] - Write readme
    # TODO: [] - Get code review

    class Menu
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

        # TODO: Don't like this here... need a better way of integrating the CRUD functionality
        def crud_menu
            CliBuilder::Crud.build_model_menu
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
        #    Other major to do = have the menus build off of files with _menu.rb at the end, pull methods from that somehow... need 
        # To know which methods to grab

    ###Include CRUD class
    class Crud < CliBuilder::Menu


            @@tables =  ActiveRecord::Base.connection.tables.select {|table| table != "schema_migrations" && table != "ar_internal_metadata"}
            @@selected_table
            @@crud_type
            def self.get_tables
                puts @@tables
            end

            def initialize(title: 'Default Menu Title', menu_options: [])
                self.title = title.downcase.gsub(/\s+/,"_").downcase.to_sym
                self.menu_options = menu_options         
                self.parent = Menu.main_menu
                self.previous_menu_option = menu_options.length + 1
                self.main_menu_option = menu_options.length + 2
                # CliBuilder::Menu.class.all << self
            end

            ##BUG! Previous Menu taks you back to main menu from crud menus

            def self.build_crud_options_menu
                crud_options = [:view, :create, :update, :destroy]
                @column_names = self.modelcase(@@selected_table).constantize.columns.map(&:name)
                puts "these are the column names! #{@column_names}"
                # Next, need to write the actual methods for view, create, update and destroy since these will get sent.
                # This will simply set the crud type and then build a menu crud by:
                crud_options.each do |crud_method|
                    puts "About to defined #{crud_method} as #{crud_method.class}"
                    define_singleton_method :"#{crud_method}" do
                        @@crud_type = crud_method
                        # this variable should be like crud_by_options
                        @crud_by_options = [:all].concat(@column_names)
                        @crud_by_options.each do |column_name|
                            puts "About to defined #{column_name} as #{column_name.class}"
                            define_singleton_method :"#{column_name}" do
                                @selected_column = "lat"
                                # Next step... populate selected column approp... make sure selected table and selected crud type stay good
                                @column_values = self.modelcase(@@selected_table).constantize.distinct.pluck(@selected_column)
                                @crud_by_value_options = [:all, @column_values]
                                @crud_by_value_options.each do |column_value|
                                    define_singleton_method :"#{column_value}" do
                                        puts "column value is #{column_value}"
                                    end
                                end
                                crud_by_value_menu = CliBuilder::Crud.new(title: "CRUD By Value Menu", menu_options: [:all].concat(@column_values))
                                crud_by_value_menu.build_menu
                                # These methods should essentially bring up a list of menu options that represents the values in that list
                                # TODO: use @column_values and @selected column to.... create a menu of the unique values
                                puts "You selected #{column_name}! The current table is #{@@selected_table} and the current crud type is #{@@crud_type}"
                            end
                        end
                        crud_by_menu = CliBuilder::Crud.new(title: "CRUD By Menu", menu_options: [:all].concat(@column_names))
                        crud_by_menu.build_menu

                    end
                end
                crud_options_menu = CliBuilder::Crud.new(title: "CRUD Options Menu", menu_options: crud_options)
                crud_options_menu.build_menu
                # puts "#
            end


            # Ulitmately, at the moment I have to include method that calls this on CliBuilder:Crud above the build_menu line.
            # What I really want is for it to all happen automatically if the user selectes --CRUD... so many this crud thing should 
            # Include it auto and overwrite if included
            def self.build_model_menu
            @methods = []
                @@tables.each_with_index do |item, index|
                    puts "about to define #{item}"
                    define_singleton_method :"#{item}" do
                        puts Crud.titlecase(item)
                        @@selected_table = item
                        puts "About to build crud options menu"
                        Crud.build_crud_options_menu
                        # TODO: this should be the actual method. So... this should store the table that was selected amd bring up the crud menu....
                    end
                    puts "#{item} is a method"
                    puts "#{item.class} is its class"
                    Crud.send(item.to_sym)
                    @methods.push(item.to_sym)
                    puts @methods
                end
                model_menu = CliBuilder::Crud.new(title: "CRUD Menu", menu_options: @methods)
                puts model_menu.class
                model_menu.build_menu
            end

            def call_menu_option(menu_option)
                if menu_option.class == self.class
                    menu_option.build_menu
                elsif self.class == CliBuilder::Crud
                    Crud.send(menu_option.to_sym)
                    build_menu
                else
                    send(menu_option)
                    build_menu
                end
            end



  
  
        # def execute_application_logic(user_input)
        #     menu_options.each_with_index do |menu_option, index|
        #         case user_input
        #         when previous_menu_option
        #             system "clear" or system "cls"
        #             parent.build_menu
        #         when main_menu_option
        #             system "clear" or system "cls"
        #             self.class.main_menu.build_menu
        #         when menu_option_number(index)
        #             system "clear" or system "cls"
        #             call_menu_option(menu_option)
        #         end
        #     end
        # end
            

            # So I have a menu with the tables...
            # Now when I fire that menu, I want to see one with crud options
            # I need to get and keep which table was selected in a variable somewhere so that I can crud on the appropriate table
        
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
  


