
module CliBuilder

    class ApplicationMenu
        # How it Works: 
        # User creates an array of menu items as symbols. Those symbols are humanized to create the menu option output, 
        # and passed to the if tree to represent the method equivalents of the menu options. They are then sent through as method messages when
        # the user selects the appropriate menu option.

        # To Use: Right now.. I am not sure how this would work as a gem. I basically took the code and put it in a file and then called application builder and input an array whenever I needed to.

        # How it could Work: The user would create a menudefinition class . Inside of this, they would define the menu using menu_definition. Then they would use methods from cli_builder to 
        #create the actual menu code

        # How it would be used:


        #So build_cli needs to take in a series of MenuDefinition objects and build the full application from that.
        def build_cli(MenuDefinitionObjects)
            build_menu(MenuDefinitionObjects)
            build_application(MenuDefinitionObjects)
        end
        
        
        #Dynamically build menu based off of methods used in this portion of the application (the portion defined by the menu)
        def build_menu(application_name, method_names)
            #take array of method names and turn into menu
            puts "#{application_name.humanize}"
            method_names.each_with_index {|method_name, index| puts "#{index + 1}: #{method_name.to_s.humanize}"}
            puts "\nPlease enter your selection:"
        end
        
        
        #Dynamically build application interaction functionality (if tree based on menu selection that runs selected methods)
        def build_application(application_name, method_names)
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

        def define_menu(name:, parent:, menu_options={} )

            #This would be the the code that creates the hash based on their arguments in the following manner:
            #The name argument is the menu title
            #If no parent is specified, the menu will default to the top level. If a parent is specified, the  menu will be an option in the parent menu.
            #The menu_otions argument should take a hash. They keys of this hash are the menu options. The values are each an array of arguments.
        end
        
        #Get user input, exit on exit
        def get_user_input
            user_input = gets.chomp
            user_input == "exit" ? exit : user_input
        end
        

        end
    end
    
end