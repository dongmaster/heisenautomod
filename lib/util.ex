defmodule Heisenautomod.Util do
  def banned_word(word) do
    text = Volapi.Util.get_text_from_message(word) |> String.downcase

    get_match(text, :banned_words)
  end

  def chat_banned_string(%{message_alt: message}) do
    get_match(message, :chat_banned_strings)
  end

  def file_special_rule(msg) do
    text = Volapi.Util.get_text_from_message(msg) |> String.downcase

    rules = get_table_contents(:file_special_rules)

    res =
        for {words, filetypes} <- rules do
          if String.contains?(text, filetypes) do
            if not String.contains?(text, words) do
              words
            end
          end
        end |> Enum.reject(&(&1 == nil)) |> List.flatten

    if res != [] do
      {true, res}
    else
      {false, res}
    end
  end

  def get_match(text, table) do
    banned_words = get_table_contents(table)

    res =
      Enum.filter(banned_words, fn(word) ->
        String.contains?(text, word)
      end)

    if res != [] do
      {true, res}
    else
      {false, res}
    end
  end

  def get_table_contents(table) do
    case :ets.lookup(table, Atom.to_string(table)) do
      [{_, contents}] ->
        contents
      _ ->
        []
    end
  end
end
