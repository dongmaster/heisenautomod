defmodule FileLogger do
  use GenServer
  @base_log_directory "logs/"
  @moduledoc """
  Logs actions to a rolling log file.
  """

  defstruct [
    current_log_filename: "",
  ]

  ## Client

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def log(data) do
    require Logger
    path = get_current_log_filename()

    {{year, month, day}, {hours, minutes, seconds, microseconds}} = Logger.Utils.timestamp(false)

    timestamp = "#{year}-#{month}-#{day} #{hours}:#{minutes}:#{seconds}.#{microseconds} [info] "

    GenServer.cast(__MODULE__, {:log, path, timestamp <> data <> "\n"})
  end

  def update_filename(new_filename) do
    GenServer.cast(__MODULE__, {:update_filename, new_filename})
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  ## Helper functions

  def get_new_log_filename() do
    {{year, month, day}, _} = :calendar.local_time
    month = if month <= 9, do: "0#{month}", else: month
    day = if day <= 9, do: "0#{day}", else: day

    "#{@base_log_directory}#{year}-#{month}-#{day}.log"
  end

  def build_initial_directory_structure() do
    if not File.exists?(@base_log_directory) do
      File.mkdir(@base_log_directory)
    end

    get_new_log_filename()
  end

  def get_current_log_filename() do
    cur_dir = get_state() |> Map.get(:current_log_filename)

    new_filename = get_new_log_filename()

    if cur_dir == new_filename do
      cur_dir
    else
      update_filename(new_filename)
      new_filename
    end
  end

  ## Server callbacks

  def init(:ok) do
    build_initial_directory_structure()

    state = %FileLogger{current_log_filename: get_new_log_filename()}

    {:ok, state}
  end

  def handle_cast({:log, path, data}, state) do
    File.write(path, data, [:append, :utf8])
    {:noreply, state}
  end

  def handle_cast({:update_filename, new_filename}, state) do
    state = Map.put(state, :current_log_filename, new_filename)
    {:noreply, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end
