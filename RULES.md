# Rule system

The rule system is just a light wrapper over Volapi with some convenience functions for timing out people and banning people.

Example rules:
```elixir
defmodule Heisenautomod.ExampleRules do
  use Heisenautomod.Rules, "example rules"
  
  # This makes it so that all chat messages are sent to the functions defined in the body below
  handle "chat" do 
    # 'func :spammers' is a way of saying "I want all messages to go to the 'spammers' function" 
    func :spammers
  end
  
  # Let's define a function that times people out based on their names, because they're spammers.
  timeout :nick, ["spammer1", "some_spammer", "imdumb"], :medium, :spammers

  # Let's go through what's happening here, one section at a time
  # > timeout
  # This is a special macro (function) that takes 4 parameters (inputs). All parameters must be comma-delimited (separated with a ,).
  # Available options:
  # 1. timeout/timeout_regex (will timeout a person based on certain critera)
  # 2. ban/ban_regex (will ban a person based on certain criteria)
  # 3. delete/delete_regex (will delete a file based on certain criteria)
  
  # > :nick
  # This specifies what to check when the function does its magic.
  # ':nick' means nickname, or rather, the name someone uses on Volafile.
  # Right now, this function times people out based on what name they're using.
  # The available options for this section are available here: 
  # 1. https://github.com/dongmaster/volapi/blob/master/lib/volapi/message/chat.ex
  # 2. https://github.com/dongmaster/volapi/blob/master/lib/volapi/message/file.ex
  # At the top of the files, you can see a bunch of "keys" (:nick is a key). You can technically use any of these keys instead of :nick, if you choose to.

  # > ["spammer1", "some_spammer", "imdumb"]
  # This is a list of names. This list is gone through everytime a message is sent to the function.
  # If any of names from the list can be found within the name from a message, that person is then timed out.
  # String.contains?/2 is used for this.
   
  # > :medium
  # This determines the length of the timeout.
  # The available options are these:
  # 1. :short
  # 2. :medium
  # 3. :long
  # 4. Any number equal to or below 86400. The value is in seconds. So if you specify "10", the user will be timed out for 10 seconds.
   
  # > :spammers
  # Behind the scenes, you're really just creating an elixir function when you use 'timeout', 'ban' or 'delete'.
  # You need to define a name for all functions in elixir, so :spammers will be the name of this function.
end
```

Do take care that you use different function names for each macro.
It would not be wise to do this:
```elixir
defmodule Heisenautomod.CoolRools do
  handle "chat" do
    func :uncool_people
  end
  
  timeout_regex :nick, [~r"^a$", ~r"^b$", ~r"^c$"], 60, :uncool_people
  timeout_regex :nick, [~r"^d$", ~r"^e$", ~r"^f$"], 120, :uncool_people
end
```

This would not work because the first function (that bans people using the names a, b and c) would consume all messages and not allow the second function to get any messages.

### Macro information

### `timeout` inputs
1. key
2. triggers
3. length - Seconds
4. function name

### `ban` inputs
1. key
2. triggers
3. options (ask dongo about this if you're a mod)
4. function name

### `delete` inputs
1. key
2. triggers
3. function name
