# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :heisenautomod, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:heisenautomod, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
config :volapi,
  nick: "your_username",
  password: "your_password",
  auto_login: true,
  rooms: ["di3fdlsi5"] # This is a list of rooms that you want the bot to join. The default room is not really a room.

config :heisenautomod,
  # The following is a list of strings (words) that will trigger the auto file deleter.
  banned_words: [".ts", ".docx"],
  file_size_limit: 500_000_000, # This is in bytes.
  # If a user uses any of the below words (default: fuck, test), they will be timed out.
  chat_banned_strings: ["fuck", "test"],
  # The format is as follows:
  # A list
  # [
  #   A tuple with two lists in it.
  #   {[], []}
  #
  #   The first list is for words that MUST be in the filename
  #   The second list is usually for filetypes, like .jpg.
  #   So the rules are like this: If an element from the second list is found in a filename, at least one item from the first list MUST be in the filename.
  # ]
  file_special_rules: [
    {["request", "reqs"], [".jpg", ".jpeg"]},
    {["cool"], [".png"]}
  ],
  # This is a reverse version of the above option.
  # It works like this:
  # If a string from the second list is found in a filename, AND if any of the strings in the first list is also in the filename, the file is deleted.
  reverse_file_special_rules: [
    {["request"], [".mp4"]}
  ]

config :ssl, protocol_version: :"tlsv1.2"