defmodule Heisenautomod.Rules do
  defmacro __using__(module_name) do
    quote bind_quoted: [module_name: module_name] do
      use Volapi.Module, module_name
      import Heisenautomod.Rules

      @module_name module_name
      #@before_compile Heisenautomod.Rules

      # def handle_cast(:init, state) do
      #   {:noreply, %{count: 0, func: :"rule#{:erlang.unique_integer([:positive])}"}}
      # end

      # def handle_call(:get_func, _from, %{count: count} = state) do
      #   if count < 2 do
      #     {:reply, state.func, Map.put(state, :count, state.count + 1)}
      #   else
      #     new_func = "rule#{:erlang.unique_integer([:positive])}"
      #     {:reply, new_func, Map.put(state, :count, 0)}
      #   end

      # end

      # def handle_cast(:update_func, state) do
      #   {:noreply, :erlang.unique_integer([:positive])}
      # end

      # def module_init() do
      #   GenServer.cast(__MODULE__, :update_func)
      # end
    end
  end

  # def get_func() do
  #   quote do
  #     GenServer.call(__MODULE__, :get_func)
  #   end
  # end

  # def update_func() do
  #   quote do
  #     GenServer.cast(__MODULE__, :update_func)
  #   end
  # end

  # defmacro timeout(:chat, do: body)https://elixir-lang.org/getting-started/introduction.html do
  #   # func = get_func()

  #   quote do
  #     handle "chat" do
  #       unquote(body)
  #     end
  #   end
  # end

  defmacro func(fun) do
    quote do
      match_all unquote(fun)
    end
  end

  # defmacro timeout(:file, do: body) do
  #   quote do
  #     handle "file" do
  #       unquote(body)
  #     end
  #   end
  # end

  defmacro timeout(_key, [], length, _func_name) do
  end

  defmacro timeout(key, trig, length, func_name) when is_list(trig) and is_binary(hd(trig)) do
    timeout_string(key, trig, length, func_name)
  end

  defmacro timeout(key, trig, length, func_name) when is_binary(trig) do
    timeout_string(key, [trig], length, func_name)
  end

  defmacro timeout(key, trig, func_name) when is_list(trig) and is_binary(hd(trig)) do
    timeout_string(key, trig, :medium, func_name)
  end

  defmacro timeout(key, trig, func_name) when is_binary(trig) do
    timeout_string(key, [trig], :medium, func_name)
  end

  def timeout_string(key, trig_list, length, func_name) do
    quote do
      defh unquote(func_name)(%{nick: nick, id: id, room: room}) do
        if Heisenautomod.Rules.check_message(unquote(trig_list), var!(message), unquote(key)) do
          Volapi.Client.Sender.timeout_chat(id, nick, unquote(length), room)
        end
      end

      defh unquote(func_name)(%{nick: nick, file_id: id, room: room}) do
        if Heisenautomod.Rules.check_message(unquote(trig_list), var!(message), unquote(key)) do
          Volapi.Client.Sender.timeout_file(id, nick, unquote(length), room)
        end
      end
    end
  end

  def check_message(trig_list, message, key) do
    Enum.any?(trig_list, fn(trig) ->
      String.contains?(Map.get(message, key), trig)
    end)
  end

  # def timeout_string(key, [trig | t], func_name) do
  #   quote do
  #     defh unquote(func_name)(%{nick: nick, id: id, room: room}) do
  #       if String.contains?(Map.get(var!(message), unquote(key)), unquote(trig)) do
  #         Volapi.Client.Sender.timeout_chat(id, nick, room)
  #       end
  #     end
  #   end

  #   timeout_string(key, t, func_name)
  # end

  defmacro timeout_regex(key, trig, func_name) when is_list(trig) do
    timeout_regex_func(key, trig, :medium, func_name)
  end

  defmacro timeout_regex(key, trig, func_name) do
    timeout_regex_func(key, [trig], :medium, func_name)
  end

  defmacro timeout_regex(key, trig, length, func_name) when is_list(trig) do
    timeout_regex_func(key, trig, length, func_name)
  end

  defmacro timeout_regex(key, trig, length, func_name) do
    timeout_regex_func(key, [trig], length, func_name)
  end

  def timeout_regex_func(key, trig_list, length, func_name) do
    quote do
      defh unquote(func_name)(%{nick: nick, id: id, room: room}) do
        if Heisenautomod.Rules.check_message_regex(unquote(trig_list), var!(message), unquote(key)) do
          Volapi.Client.Sender.timeout_chat(id, nick, unquote(length), room)
        end
      end

      defh unquote(func_name)(%{nick: nick, file_id: id, room: room}) do
        if Heisenautomod.Rules.check_message_regex(unquote(trig_list), var!(message), unquote(key)) do
          Volapi.Client.Sender.timeout_file(id, nick, unquote(length), room)
        end
      end
    end
  end

  def check_message_regex(trig_list, message, key) do
    Enum.any?(trig_list, fn(trig) ->
      Regex.match?(trig, Map.get(message, key))
    end)
  end

  defmacro ban(key, trig, options, func_name) when is_list(trig) do
    ban_user(key, trig, options, func_name)
  end

  defmacro ban(key, trig, options, func_name) do
    ban_user(key, [trig], options, func_name)
  end

  def ban_user(key, trig_list, options, func_name) do
    quote do
      defh unquote(func_name)(%{ip: ip, room: room}) do
        if Heisenautomod.Rules.check_message(unquote(trig_list), var!(message), unquote(key)) do
          Volapi.Client.Sender.ban_user(ip, unquote(options), room)
        end
      end
    end
  end

  defmacro ban_regex(key, trig, options, func_name) when is_list(trig) do
    ban_user_regex(key, trig, options, func_name)
  end

  defmacro ban_regex(key, trig, options, func_name) do
    ban_user_regex(key, trig, options, func_name)
  end

  def ban_user_regex(key, trig_list, options, func_name) do
    quote do
      defh unquote(func_name)(%{ip: ip, room: room}) do
        if Heisenautomod.Rules.check_message_regex(unquote(trig_list), var!(message), unquote(key)) do
          Volapi.Client.Sender.ban_user(ip, unquote(options), room)
        end
      end
    end
  end

  defmacro delete(key, trig, func_name) when is_list(trig) do
    delete_file(key, trig, func_name)
  end

  defmacro delete(key, trig, func_name) do
    delete_file(key, [trig], func_name)
  end

  def delete_file(key, trig_list, func_name) do
    quote do
      defh unquote(func_name)(%{file_id: file_id, room: room}) do
        if Heisenautomod.Rules.check_message(unquote(trig_list), var!(message), unquote(key)) do
          Volapi.Client.Sender.delete_file(file_id, room)
        end
      end
    end
  end

  defmacro delete_regex(key, trig, func_name) when is_list(trig) do
    delete_file_regex(key, trig, func_name)
  end

  defmacro delete_regex(key, trig, func_name) do
    delete_file_regex(key, [trig], func_name)
  end

  def delete_file_regex(key, trig_list, func_name) do
    quote do
      defh unquote(func_name)(%{file_id: file_id, room: room}) do
        if Heisenautomod.Rules.check_message_regex(unquote(trig_list), var!(message), unquote(key)) do
          Volapi.Client.Sender.delete_file(file_id, room)
        end
      end
    end
  end
end
