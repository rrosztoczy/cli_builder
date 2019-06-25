require "sinatra"
require "active_record"
require "sinatra/activerecord"
require_relative "./menu.rb"

module CliBuilder
    class Crud < Menu
    # TODO: [] - Complete actual CRUD methods
    # TODO: [] - Organize files appropriately
    # TODO: [] - Break out methods for CRUD Menu Generation
    # TODO: [] = Update ReadME
    # TODO: [] - Add, update tests and review organization
    # TODO: [] - Get code review

        @@tables =  ActiveRecord::Base.connection.tables.select {|table| table != "schema_migrations" && table != "ar_internal_metadata"}
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

        def self.build_crud_menu(menu_type, menu_options)
            crud_menu = CliBuilder::Crud.new(title: menu_type.to_s, menu_options: menu_options)
            crud_menu.build_menu
        end

        def self.write_record_method(crud_type, record, selected_table="")
            define_singleton_method :"#{record}" do
                # For view, find_by(@selected_column === @selected_value)
                puts "#{selected_table.find(record.id)}"
                case crud_type
                when :view
                    puts "Record information: #{record.as_json}"
                when :update
                      # When crud type is update, update the appropriate value for that column/record with the new data
                    # user = User.find_by(name: 'David')
                    # user.update(name: 'Dave')
                    puts "Choose record column for update: #{record.as_json}"
                    column_to_update = gets.chomp
                    puts "Enter new value:"
                    new_value = gets.chomp
                    record.update({column_to_update => "#{new_value}"})
                    puts "Record updated"
                when :destroy
                    record.destroy
                    puts "Record deleted"
                else
                end
           end
        end

        def self.write_crud_by_value(crud_type, column_value, records, selected_table="")
            define_singleton_method :"#{column_value}" do
                records.each do |record|
                    write_record_method(crud_type, record, selected_table)
                end
                build_crud_menu("#{crud_type.to_s}", records)
            end
        end

        def self.write_crud_by_model(crud_type, column_name, selected_table="")
            define_singleton_method :"#{column_name}" do
                column_values = selected_table.distinct.pluck(column_name)
                column_values.each do |column_value|
                    if column_name === :all
                        records = selected_table.find_each.to_a
                    else
                        records = selected_table.where("#{column_name}=?", column_value).to_a
                    end
                    puts "records are #{records}"
                    write_crud_by_value(crud_type, column_value, records, selected_table)
                end
                build_crud_menu("Choose Records by Column Value", [:all].concat(column_values))
            end
        end

        def self.create_crud_type_menu(selected_table="")
            crud_types = [:view, :create, :update, :destroy]
            column_names = selected_table.columns.map(&:name)
            crud_types.each do |crud_type|
                write_crud_by_type(crud_type, column_names, selected_table)
            end
            build_crud_menu("Select CRUD Type", crud_types)
            build_crud_type_menu(crud_types)
        end

        # Writes method to choose crud type
        def self.write_crud_by_type(crud_type, column_names, selected_table="")
            define_singleton_method :"#{crud_type}" do
                @crud_by_options = [:all].concat(column_names)
                @crud_by_options.each do |column_name|
                    puts "About to defined#{column_name} as #{column_name.class}"
                    write_crud_by_model(crud_type, column_name, selected_table)
                end
                build_crud_menu("Find Records by Column", [:all].concat(column_names))

            end

        end
    

        def self.build_model_menu(selected_table="")
        @methods = []
            @@tables.each_with_index do |item, index|
                puts "about to define #{item}"
                define_singleton_method :"#{item}" do
                    puts Crud.titlecase(item)
                    selected_table = to_table_format(item)
                    Crud.create_crud_type_menu(selected_table)
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
                Crud.send(menu_option.to_s)
                # Worth using string in menu as well? Or keep that as sym for memory?
                build_menu
            else
                send(menu_option)
                build_menu
            end
        end        
    end
end