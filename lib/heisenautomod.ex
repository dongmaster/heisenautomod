defmodule Heisenautomod do
  use Volapi.Module, "automod"
  require Logger
  #@file_size_limit 500_000_000 # This is about 500MB
  @file_size_limit 5_000_000 # This is about 500MB

  ## Enforcers

  def banned_word?(msg) do
    text = Volapi.Util.get_text_from_message(msg) |> String.downcase

    banned_words = get_banned_words

    String.contains?(text, banned_words)
  end

  def file_size_limit?(%{file_size: file_size}) do
    file_size > Application.get_env(:heisenautomod, :file_size_limit, 500_000_000)
  end

  ## Handlers

  handle "file" do
    enforce :banned_word? do
      match_all :delete_file_banned_word
    end

    enforce :file_size_limit? do
      match_all :delete_file_size_limit
    end
  end

  ## Matchers

  defh delete_file_banned_word(%{room: room, file_id: file_id, file_name: file_name, metadata: %{user: user}}) do
    Logger.info("Deleting the following file: \"#{file_name}\" uploaded by: \"#{user}\" because of a banned word.")
    Volapi.Client.Sender.delete_file(file_id, room)
    Process.sleep(60)
  end

  defh delete_file_size_limit(%{room: room, file_id: file_id, file_name: file_name, file_size: file_size, metadata: %{user: user}}) do
    Logger.info("Deleting the following file: \"#{file_name}\" uploaded by: \"#{user}\" because of the file size (#{file_size} bytes).")
    Volapi.Client.Sender.delete_file(file_id, room)
    Process.sleep(60)
  end

  ## Functions

  def module_init do
    Process.sleep(1000)
    if :ets.info(:banned_words) == :undefined do
      :ets.new(:banned_words, [:public, :named_table])

      banned_words = Application.get_env(:heisenautomod, :banned_words, [])

      :ets.insert(:banned_words, {"banned_words", banned_words})

      :timer.apply_interval(60000 * 5, __MODULE__, :check_files, [])
    end
  end

  def check_files do
    Enum.each(Application.get_env(:volapi, :rooms, []), fn(room) ->
      files = Volapi.Server.Client.get_files(room)

      Enum.each(files, fn(file) ->
        text = Volapi.Util.get_text_from_message(file) |> String.downcase

        banned_words = get_banned_words

        if String.contains?(text, banned_words) do
          Process.sleep(100)
          Volapi.Client.Sender.delete_file(file.file_id, room)
        end
      end)
    end)
  end

  def get_banned_words do
    case :ets.lookup(:banned_words, "banned_words") do
      [{_, banned_words}] ->
        banned_words
      _ ->
        []
    end
  end
end
