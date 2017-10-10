defmodule Heisenautomod.ExampleRules do
  use Heisenautomod.Rules, "example rules"

  handle "chat" do
    func :test
  end

  timeout :nick_alt, ["imdumb"], :long, fn(%{nick: nick}) -> reply "#{nick} is a pig" end, :test
end







