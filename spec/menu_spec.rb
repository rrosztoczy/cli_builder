require_relative "../lib/cli_builder/menu.rb"

RSpec.describe CliBuilder::Menu do
    let (:test_menu) {CliBuilder::Menu.new(title: "Test Menu Title!", menu_options: [:menu_option_one, :menu_option_two, :menu_option_three])}
    #Unit test for menu title writing
    it "has instances which can write their own titles" do
        expect{test_menu.build_menu_title}.to output("Test Menu Title!\n\n").to_stdout
    end
    it "has instances which can display their menu options in the terminal" do
        expect{test_menu.build_menu_body}.to output("1. Menu Option One\n2. Menu Option Two\n3. Menu Option Three\n\nPlease enter your selection:\n").to_stdout
    end
    # it "has instances which can build the logic underlying the selection of its available menu options" do
    #     expect{test_menu.build_menu_body}.to output("1. Menu Option One\n2. Menu Option Two\n3. Menu Option Three\nPlease enter your selection:\n").to_stdout
    # end
  end


