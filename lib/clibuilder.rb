require "clibuilder/version"

module Clibuilder
  class Error < StandardError; end


#Build out terminal application menu and user interaction behavior
module CLI_Builder

  #The ApplicationInterfaceBuilder class is responsible for building the menus and application interaction functionality (the if tree and method calls that underly the menu functionality).
  class ApplicationInterfaceBuilder

    def application_builder(application_name, method_names)
        build_menu(application_name, method_names)
        build_if_tree(application_name, method_names)
      end
      
      
      #Dynamically build menu based off of methods used in this portion of the application (the portion defined by the menu)
      def build_menu(application_name, method_names)
        #take array of method names and turn into menu
        puts "#{application_name.humanize}"
        method_names.each_with_index {|method_name, index| puts "#{index + 1}: #{method_name.to_s.humanize}"}
        puts "\nPlease enter your selection:"
      end
      
      
      #Dynamically build application interaction functionality (if tree based on menu selection that runs selected methods)
      def build_if_tree(application_name, method_names)
        user_input = get_user_input
      
        #title page------
        title
        #end title page----
      
          #look through each option and compare to input, if it has an associated method, run it. If no matches, prompt to enter a valid option and start again.
          method_names.each_with_index do |method_name, index|
            if user_input.to_i == index + 1
              #had return send(method_name)
              send(method_name)
            end
          end
              #returns error message if not a valid option
              if !user_input.to_i.between?(1, method_names.length)
              puts "\n****Error: Please enter a valid number****"
              puts "\n"
              application_builder(application_name, method_names)
              end
        end
      
      #Get user input, exit on exit
      def get_user_input
        user_input = gets.chomp
        user_input == "exit" ? exit : user_input
      end
      
      
      
      def main_menu
          main_menu_array = [:start_new_ride, :ride_menu, :location_menu]
          application_builder("Main Menu", main_menu_array)
      end

      end
    end


  #CRUD Class
  class CLI_CRUD
    def self.ride_by_type_menu
      ride_type_array = ["UberX & lyft", "UberXL & lyft_plus", "Black & lyft_lux", "Black SUV & lyft_luxsuv", "UberPool & lyft_line"]
    
      #Dynamically defines methods for the application builder using the product types
      ride_type_array.each_with_index do |mapped_product_type, index|
        define_method :"#{mapped_product_type}" do
    
          #breaks apart product types to access appropriate db values
          uber = mapped_product_type.split(" & ")[0]
          lyft = mapped_product_type.split(" & ")[1]
          uber_rides_arr = Ride.where(product_type: "#{uber}")
          lyft_rides_arr = Ride.where(product_type: "#{lyft}")
    
          #formats and puts out ride data
          puts "Ride prices by product type:"
          puts "\n"
          rides_arr = (uber_rides_arr + lyft_rides_arr).sort_by {|ride| ride.name}
          rides_arr.each do |ride|
            puts "#{ride.name.ljust(40)} #{ride.product_type.ljust(12)} avg $#{ride.avg_estimate.to_s.ljust(12)} est #{ride.estimate.ljust(12)} #{ride.created_at}"
          end
          puts "\n"
          ride_menu
        end
      end
    
      #Builds dynamic application menu and functionality from product definitions
      application_builder("Find Ride Data by Type", ride_type_array)
  #   end
  end
end
