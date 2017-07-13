defmodule Heisenautomod do
  use Volapi.Module, "automod"
  require Logger
  alias Volapi.Client.Sender
  @tables [:banned_words, :chat_banned_strings, :file_special_rules, :reverse_file_special_rules, :deleted_self]

  ## Enforcers

  def banned_word?(msg) do
    {res, triggers} = Heisenautomod.Util.banned_word(msg)

    res
  end

  def file_size_limit?(%{file_size: file_size}) do
    file_size > Application.get_env(:heisenautomod, :file_size_limit, 525_000_000)
  end

  def chat_banned_string?(msg) do
    {res, triggers} = Heisenautomod.Util.chat_banned_string(msg)

    res
  end

  def file_special_rule?(msg) do
    {res, triggers} = Heisenautomod.Util.file_special_rule(msg)

    res
  end

  def reverse_file_special_rule?(msg) do
    {res, triggers} = Heisenautomod.Util.reverse_file_special_rule(msg)

    res
  end

  def not_staff(%{staff: staff}) do
    not staff
  end

  def logged_in?(%{logged_in: state}) do
    state
  end

  def deleted_self?(%{file_id: file_id}) do
    Heisenautomod.Util.get_table_contents(:deleted_self, file_id) != []
  end

  ## Handlers

  handle "chat" do
    enforce :not_staff do
      enforce :chat_banned_string? do
        match_all :timeout_user
      end
    end
  end

  handle "file" do
    enforce :banned_word? do
      match_all :delete_file_banned_word
    end

    enforce :file_size_limit? do
      match_all :delete_file_size_limit
    end

    # I have no idea what to call this function.
    enforce :file_special_rule? do
      match_all :delete_file_special_rule
    end

    enforce :reverse_file_special_rule? do
      match_all :delete_file_special_rule
    end
  end

  handle "file_delete" do
    enforce :deleted_self? do
      match_all :file_deleted
    end
  end

  handle "logged_in" do
    enforce :logged_in? do
      match_all :logged_in
    end
  end

  ## Matchers

  defh hello do
    reply "hello!"
  end

  defh logged_in do
    reply_admin "Logged in!"
  end

  defh file_deleted(%{room: room, file_id: file_id, file_name: file_name, file_size: file_size, nick: user}) do
    :ets.delete(:deleted_self, file_id)

    {_, triggers} = Heisenautomod.Util.banned_word(message)

    all_triggers = triggers

    extra_s = if Enum.count(all_triggers) > 1, do: "s", else: ""
    possible_trigger_words = if Enum.count(all_triggers) > 0, do: " possible trigger word#{extra_s} for deletion: #{Enum.join(all_triggers, ", ")}", else: ""

    limit = Application.get_env(:heisenautomod, :file_size_limit)
    diff = limit - file_size

    FileLogger.log("Deleted the following file: \"#{file_name}\" uploaded by: \"#{user}\" file size: \"#{file_size}\" (limit: #{limit} | difference: #{diff})#{possible_trigger_words}")
  end

  defh file_deleted do
    IO.inspect message
  end

  defh delete_file_banned_word(%{room: room, file_id: file_id, file_name: file_name, nick: user}) do
    :ets.insert(:deleted_self, {file_id, file_id})
    Sender.delete_file(file_id, room)
    Process.sleep(60)
  end

  defh delete_file_size_limit(%{room: room, file_id: file_id, file_name: file_name, file_size: file_size, nick: user}) do
    :ets.insert(:deleted_self, {file_id, file_id})
    Sender.delete_file(file_id, room)
    Process.sleep(60)
  end

  defh delete_file_special_rule(%{room: room, file_id: file_id, file_name: file_name, nick: user}) do
    :ets.insert(:deleted_self, {file_id, file_id})
    Sender.delete_file(file_id, room)
    Process.sleep(60)
  end

  defh timeout_user(%{nick: nick, message: msg, id: id, room: room, user: logged_in, admin: admin, donator: donator, staff: staff}) do
    {_, triggers} = Heisenautomod.Util.chat_banned_string(message)

    extra_s = if Enum.count(triggers) > 1, do: "s", else: ""

    FileLogger.log("Timing out \"#{nick}\" (Logged in: #{logged_in} | Donator: #{donator}) because of the following message: \"#{msg}\" The following word#{extra_s} triggered the timeout: #{Enum.join(triggers, ", ")}")

    Sender.timeout_chat(id, nick, room)
  end

  ## Functions

  def module_init do
    Process.sleep(1000)
    Enum.each(@tables, fn(table) ->
      if :ets.info(table) == :undefined do
        :ets.new(table, [:public, :named_table, {:write_concurrency, true}, {:read_concurrency, true}])

        banned_words = Application.get_env(:heisenautomod, table, [])

        :ets.insert(table, {Atom.to_string(table), banned_words})
      end
    end)

    :timer.apply_interval(30000, __MODULE__, :check_files, [])
  end

  def check_files do
    Enum.each(Application.get_env(:volapi, :rooms, []), fn(room) ->
      files = Volapi.Server.Client.get_files(room)

      funcs = [
        {Heisenautomod.Util, :banned_word},
        {Heisenautomod.Util, :file_special_rule},
        {Heisenautomod.Util, :reverse_file_special_rule}
      ]

      Enum.each(files, fn(file) ->
        Enum.each(funcs, fn({module, func}) ->
          {res, triggers} = apply(module, func, [file])

          if res do
            Process.sleep(100)
            Volapi.Client.Sender.delete_file(file.file_id, room)
          end
        end)
      end)
    end)
  end
end
