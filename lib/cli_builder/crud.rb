require "sinatra"
require "active_record"
require "sinatra/activerecord"
require_relative "./menu.rb"

module CliBuilder
    class Crud < Menu
    # TODO: [] - Organize files appropriately
    # TODO: [] - Break out methods for CRUD Menu Generation
    # TODO: [] = Update ReadME
    # TODO: [] - Review tests and test organization
    # TODO: [] - Get code review

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

        def crud_menu
            self.build_model_menu
        end

        # Add a formatting file for this method, modelcase from menu, etc
        def self.to_table_format(table)
            self.modelcase(table).constantize
        end

        def self.write_crud_method(crud_type, column_names)
            define_singleton_method :"#{crud_type}" do
                @@crud_type = crud_type
                # this variable should be like crud_by_options
                @crud_by_options = [:all].concat(column_names)
                @crud_by_options.each do |column_name|
                    puts "About to defined#{column_name} as #{column_name.class}"
                    define_singleton_method :"#{column_name}" do
                        @selected_column = column_name
                        # Next step... populate selected column approp... make sure selected table and selected crud type stay good
                        @column_values = @@selected_table.distinct.pluck(@selected_column)
                        @column_values.each do |column_value|
                            # It looks like all option does not work with below statement... if column_value = all... do an all statement
                            if @selected_column === :all
                                @records = @@selected_table.find_each.to_a
                            else
                                @records = @@selected_table.where("#{@selected_column}=?", column_value).to_a
                            end
                            puts "records are #{@records}"
                            define_singleton_method :"#{column_value}" do
                                puts "column value is #{column_value}"
                                @selected_value = column_value
                            
                                @records.each do |record|
                                    puts "#{record.attributes}"
                                    # Should probably make the menu items be the above ^
                                    puts "#{record.attributes.values}"
                                    define_singleton_method :"#{record}" do
                                         # For view, find_by(@selected_column === @selected_value)
                                         puts "#{@@selected_table.find(record.id)}"

                                    end
                                    # record.crudtype?
                                   
                                end
                                crud_by_record_menu = CliBuilder::Crud.new(title: "#{@@crud_type.to_s}", menu_options: @records)
                                crud_by_record_menu.build_menu
                                # What do Iant to do here? Bring up all records that have that value?
                                # When they enter a selection, I want to see all records of that type
                                # When they enter that selection, I want to execute the actual crud using @crud_method, @table, @column name, etc.
                                # Or maybe just the id
                            end
                        end
                        crud_by_value_menu = CliBuilder::Crud.new(title: "CRUD By Value Menu", menu_options: [:all].concat(@column_values))
                        crud_by_value_menu.build_menu
                        # These methods should essentially bring up a list of menu options that represents the values in that list
                        # TODO: use @column_values and @selected column to.... create a menu of the unique values
                        puts "You selected #{column_name}! The current table is #{@@selected_table} and the current crud type is #{@@crud_type}"
                    end
                end
                crud_by_menu = CliBuilder::Crud.new(title: "CRUD By Menu", menu_options: [:all].concat(column_names))
                crud_by_menu.build_menu

            end

        end

        def self.build_crud_type_menu
            crud_options = [:view, :create, :update, :destroy]
            column_names = @@selected_table.columns.map(&:name)
            crud_options.each do |crud_method|
                puts "About to define #{crud_method} as #{crud_method.class}"
                write_crud_method(crud_method, column_names)
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
                    @@selected_table = to_table_format(item)
                    puts "About to build crud options menu"
                    # TODO: This is in the wrong place, should see a table menu
                    Crud.build_crud_type_menu
                    # TODO: this should be the actual method. So... this should store the table that was selected amd bring up the crud menu....
                    puts "#{item} is a method"
                    puts "#{item.class} is its class"
                    # Crud.send(item.to_sym)
                end
                @methods.push(item.to_sym)
                puts @methods
            end
            model_menu = CliBuilder::Crud.new(title: "CRUD Menu", menu_options: @methods)
            puts model_menu.class
            model_menu.build_menu
        end

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



