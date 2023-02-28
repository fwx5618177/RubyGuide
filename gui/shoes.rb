require 'shoes'

Shoes.app do
  background "#DFA"
  title "My Amazing App!"

  stack(margin: 12) do
    para "Enter your name:"
    @edit = edit_line

    button "Click me" do
      @message.replace "Hello, #{@edit_text}!"
    end
  end

  @message = para "Nothing to say yet."
end