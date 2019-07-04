require "sinatra"
require "active_record"
require "sinatra/activerecord"
# require_relative "./menu.rb"

module Crud
    #TODO: The issue I am currently running into is how to write the methods for the crud menus and send them to the menus appropriately. Look into whether they are
    #Even being written first, then look into how you can send them.
    #Refactor notes
    # What is this class responsible for? At the moment it has multiple responsibilities:
    #
    # 1. It is responsible for automating the creation of methods and menu objects to enable user CRUD through a simple CLI interface and the active record ORM
    #    > It will likley make future development easier if I seperate it into two classes, one which writes the methods, and one which creates the menus
    # 2. Additionally, there are a variety of other method types in this class that are only tangentially related including formatting, user input prompt and
    #    manipulation and validations
    # 3. Finally, there is a dupicate method with added functionality from the inheritied class.
    #
    # 4. Another curiosity is my high use of class methods. Are these actually necessary for the automation, or can I be more deliberate about the creation of 
    #    these menu instances and the messages being sent between them?
    #
    # 5. Another interesting thing is my high use of arguments - these should likely be instance variables tied to the appropriate class. This would also make 
    #    the delineation of the different classes and their responsiblities more clear. Additionally, if I reorg for each menu to have a set of appropriate instance
    #    variables on creation (or just use the menu class and provide it the appropriate variables) than my data and behaviour will be tighter and less coupled.
    #
    # What is each method responsible for? Many of these are tightly coupled.

    #TODO: Extract classes to improve cohesion and enforce SRP and evaluate whether inheritance is necessary at all
    #TODO: Extract methods to improve cohesion and enforce SRP
    # WIP: replace heavy argument usage with appropriate variable/message passing

    # Afterwards:
    #TODO: Complete a dependency evaluation

        @@tables =  ActiveRecord::Base.connection.tables.select {|table| table != "schema_migrations" && table != "ar_internal_metadata"}
        @@crud_type
        @@selected_table
        def self.get_tables
            puts @@tables
        end

        def crud_menu
            self.build_model_menu
        end

        # Add a formatting file for this method, modelcase from menu, etc
        def to_table_format(table)
            #change to format module
            CliBuilder::Menu.modelcase(table).constantize
        end

        def verify_method(records, selected_record)
            puts "Are you sure you want to #{@@crud_type} #{selected_record}? (Y/N)"
            user_verification = gets.chomp
            case user_verification
            when "Y" || "y"
            return
            when "N" || "n"
            puts "Did not #{@@crud_type} #{selected_record}"
            build_crud_menu("#{@@crud_type.to_s}", records)
            else 
                puts "Please enter Y or N"
                verify_method
            end
        end

        def build_crud_menu(menu_type, menu_options)
            crud_menu = CliBuilder::Menu.new(title: menu_type.to_s, menu_options: menu_options, menu_type: "crud")
            crud_menu.build_menu
        end

        # TODO: To print record info, iterate through column values and print wiht |

        def write_record_method(menu, records, selected_record)
            puts "I am record method #{self}"
            menu.define_singleton_method :"#{selected_record}" do
                puts "#{@@selected_table.find(selected_record.id)}"
                case @@crud_type
                when :view
                    puts "Record information: #{selected_record.as_json}"
                when :update
                    puts "Record information: #{selected_record.as_json}"
                    puts "Please enter a record attribute to update:"
                    column_to_update = gets.chomp
                    value_before_update = selected_record[column_to_update.to_sym]
                    puts "The current value for #{column_to_update} is #{value_before_update}. Please enter the new value:"
                    new_value = gets.chomp
                    verify_method(records, selected_record)
                    selected_record.update({column_to_update => "#{new_value}"})
                    puts "#{column_to_update} has been updated to #{new_value} from #{value_before_update}"
                    menu.build_menu
                when :destroy
                    verify_method(records, selected_record)
                    selected_record.destroy
                    puts "Record deleted"
                    new_records = records.filter {|record| record != selected_record}
                    menu.build_menu
                else
                end
           end
        end

        def write_crud_by_value(menu, column_value, records)
            crud_by_record_menu = CliBuilder::Menu.new(title: "Choose Record for CRUD", menu_options: records, menu_type: "crud")
            menu.define_singleton_method :"#{column_value}" do
                records.each do |record|
                    write_record_method(crud_by_record_menu, records, record)
                end
                crud_by_record_menu.build_menu
            end
        end

        def write_crud_by_model(menu, column_name)
            column_values = @@selected_table.distinct.pluck(column_name)
            crud_by_value_menu = CliBuilder::Menu.new(title: "Choose Value for CRUD", menu_options: column_values, menu_type: "crud")
            menu.define_singleton_method :"#{column_name}" do
                column_values.each do |column_value|
                    if column_name === :all
                        records = @@selected_table.find_each.to_a
                    else
                        records = @@selected_table.where("#{column_name}=?", column_value).to_a
                    end
                    write_crud_by_value(crud_by_value_menu, column_value, records)
                end
                crud_by_value_menu.build_menu
            end
        end

        def create_crud_type_menu
            crud_types = [:view, :create, :update, :destroy]
            crud_type_menu = CliBuilder::Menu.new(title: "Select Type of CRUD", menu_options: crud_types, menu_type: "crud")
            crud_types.each do |crud_type|
                write_crud_by_type(crud_type_menu, crud_type)
            end
            crud_type_menu.build_menu
        end

        # Writes method to choose crud type
        def write_crud_by_type(menu, crud_type)
            column_names = @@selected_table.columns.map(&:name)
            crud_by_options = [:all].concat(column_names)
            crud_column_menu = CliBuilder::Menu.new(title: "Select Type of CRUD", menu_options: crud_by_options, menu_type: "crud")
            menu.define_singleton_method :"#{crud_type}" do
                @@crud_type = crud_type
                crud_by_options.each do |column_name|
                    write_crud_by_model(crud_column_menu, column_name)
                end
                crud_column_menu.build_menu
            end
        end
    

        def build_model_menu
        @methods = []
        model_menu = CliBuilder::Menu.new(title: "CRUD Menu", menu_options: @methods, menu_type: "crud")
            @@tables.each_with_index do |item, index|
                model_menu.define_singleton_method :"#{item}" do
                    @@selected_table = to_table_format(item)
                    model_menu.create_crud_type_menu
                end
                @methods.push(item.to_sym)
            end
            model_menu.menu_options = @methods
            model_menu.build_menu
        end   
end