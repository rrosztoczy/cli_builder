class Menu #modularize cli_builder later?
        attr_accessor :title, :parent, :menu_options
        @@all = []

        def initialize(title: 'default menu title', parent: nil,  menu_options: [])
            # super #is this necessary to allow for other methods to still be useable or not necessary?

            #This would be the the code that creates the hash based on their arguments in the following manner:
            #The name argument is the menu title, the parent associates a sub-menu with a parent-menu, the menu_options are the options that can be
            # selected from the menu. These are usually either sub-menus or methods to be run. 

            #If no parent is specified, the menu will default to the top level. If a parent is specified, the  menu will be an option in the parent menu.
            #The menu_otions argument should take a hash. They keys of this hash are the menu options. The values are each an array of arguments.

            #So this will be an object that CliBuilder will use to build out the application.
            #I think it would be userful to format all inputs in symbol like form for passing around as messages and then reformatting on display depending
            #on the usecase... but this may not be necessary
            self.title = title.downcase.gsub(/\s+/,"_").downcase.to_sym
            if parent != nil
                self.parent = parent.gsub(/\s+/,"_").downcase.to_sym
            else 
                self.parent = parent
            end
            self.menu_options = menu_options
            Menu.all << self
        end

        def self.all
            @@all
        end

        #TODO: Build in parent functionality.
        # This should allow:
        # Build all to loop through menus
        # Putting an exit option to the previous menu
        #Error messaging during build around building sub menus first, warning messaging if no parent and another menu object has no parent. This could be allowed
        #in certain cases let's say new user vs experienced user for instance but make sure it is meant.

        #Functionality to print out menus to terminal for evaluation
        def self.preview_all
             #Chain through menus and submenus, printing all
        end

        def preview
            self.build_menu_body
        end


        #Functionality for building out menus Menu.build and self.Menu.build_all
        def self.build_all
            #Chain through menus and submenus, building all
            # How would this work? If a submenu is actually a collection of more menu options, I need to loop thorugh that level too.
            
            #Need to iterate through all menus and do the following:
            Menu.all.each do |menu|
            #Build top parent level menu:
                # If self.parent == nil #&& #@@all includes another menu with no parent
                # #Show warning. Allow to continue with (Y/N)
                #     if user_input == n
                #         exit
                #     elsif user_input == y
                #         # rescue
                #     else
                #         puts "Please enter Y or N"
                #     end
                # elsif self.parent == nil #&& #@@all does not include another menu with no parent
                #build parent menu
                self.build_menu_body
                self.build_application
                # elsif self.parent == #an menu object

                #Build second layer menu, stick in parent, make sure there is a back to second.

                #continue
                # end
            end

        end


        def build
            self.build_menu_body
            self.build_application
        end

        #functionality to clear out current menus for redesign

        def clear
        end

        def self.clear_all
        end

        #Funtionality for formatting
        def format
        end

      

    

        # ****************************************************Print and Builder Code********************************************************************

    # private
    
    
    #Dynamically build menu based off of methods used in this portion of the application (the portion defined by the menu)

    def titlecase(string)
        string.split("_").each {|word| word.capitalize!}.join(" ")
    end

    def build_menu_title
        puts "#{titlecase(self.title.to_s)}"
    end

    def build_menu_body
        #take array of method titles and turn into menu
        menu_options.each_with_index {|menu_option, index| puts "#{index + 1}: #{menu_option.to_s.humanize}"}
        puts "\nPlease enter your selection:"
    end
    
    
    #Dynamically build application interaction functionality (if tree based on menu selection that runs selected methods)
    def build_application
        user_input = get_user_input
    
        #look through each option and compare to input, if it has an associated method, run it. If no matches, prompt to enter a valid option and start again.
        self.menu_options.each_with_index do |menu_option, index|
            if user_input.to_i == index + 1
                #had return send(menu_options)
                send(menu_option)
            end
        end
            #returns error message if not a valid option
        if !user_input.to_i.between?(1, menu_options.length)
            puts "\n****Error: Please enter a valid number****"
            puts "\n"
            #TODO: How to handle this looping?
            # application_builder(application_name, menu_options)
        end
    end

    #Get user input, exit on exit
    def get_user_input
        user_input = gets.chomp
        user_input == "exit" ? exit : user_input
    end

    



end


