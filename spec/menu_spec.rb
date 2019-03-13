require_relative "../lib/cli_builder/menu.rb"

RSpec.describe Menu do
    # it "has a version number" do
    #   expect(CliBuilder::VERSION).not_to be nil
    # end

    # it "does something useful" do
    #   expect(false).to eq(true)
    # end

    #Create menu instance to test
    let (:test_menu) {Menu.new(title: "Test Menu Title!", parent: nil, menu_options: [:menu_option_one, :menu_option_two, :menu_option_three])}
    #Unit test for menu title writing
    it "has instances which can write their own titles" do
        expect{test_menu.build_menu_title}.to output("Test Menu Title!\n").to_stdout
    end
    it "has instances which can display their menu options in the terminal" do
        expect{test_menu.build_menu_body}.to output("1. Menu Option One\n2. Menu Option Two\n3. Menu Option Three\n").to_stdout
    end
  end


