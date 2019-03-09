module CliBuilder

    class MenuDefinition
        attr_accessor :name, :parent, :menu_options

        def initialize(name: 'default menu name', parent: nil,  menu_options: {})
            # super #is this necessary to allow for other methods to still be useable or not necessary?
            #This would be the the code that creates the hash based on their arguments in the following manner:
            #The name argument is the menu title
            #If no parent is specified, the menu will default to the top level. If a parent is specified, the  menu will be an option in the parent menu.
            #The menu_otions argument should take a hash. They keys of this hash are the menu options. The values are each an array of arguments.

            #So this will be an object that CliBuilder will use to build out the application.
            self.name = name.downcase.gsub(/\s+/,"_").downcase.to_sym
            if parent != nil
                self.parent = parent.gsub(/\s+/,"_").downcase.to_sym
            else 
                self.parent = parent
            end
            self.menu_options = menu_options
        end

    end

end


#TODO: Write code that will build the menus based of hte inputs. Thing about how to make sure menu_options can be passed thorugh with useful args.
