# Any text that comes after a # in this file will be ignored by elixir/the bot.
# If you want to enable an option for the bot, just remove the # at the start of the line.
# If you look below, you'll see an option called banned_words: [".ts", ".docx"]

use Mix.Config


config :volapi,
  nick: "your_username",
  password: "your_password",
  auto_login: true,
  rooms: ["di3fdlsi5"] # This is a list of rooms that you want the bot to join. The default room is not really a room.

config :heisenautomod,
  # The following is a list of strings (words) that will trigger the auto file deleter.
  # Example
  # banned_words: [".ts", ".docx"],
  banned_words: [],
  file_size_limit: 20971520001, # This is in bytes.
  # If a user uses any of the below words (default: fuck, test), they will be timed out.
  # Example:
  # chat_banned_strings: ["fuck", "test"],
  chat_banned_strings: [],
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
  # Example:
  # file_special_rules: [
  #   {["request", "reqs"], [".jpg", ".jpeg"]},
  #   {["cool"], [".png"]}
  # ]
  file_special_rules: [
  ],
  # This is a reverse version of the above option.
  # It works like this:
  # If a string from the second list is found in a filename, AND if any of the strings in the first list is also in the filename, the file is deleted.
  # Example:
  # reverse_file_special_rules: [
  #   {["request"], [".mp4"]}
  # ]
  reverse_file_special_rules: [
  ]

config :ssl, protocol_version: :"tlsv1.2"
