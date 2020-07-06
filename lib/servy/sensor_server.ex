defmodule Servy.SensorServer do
  @name :sensor_server

  use GenServer

  defmodule State do
    defstruct interval: :timer.seconds(5), sensor_data: %{}
  end

  # CLIENT INTERFACE

  def start do
    IO.puts("starting up sensor server...")
    GenServer.start(__MODULE__, %State{}, name: @name)
  end

  def get_sensor_data do
    GenServer.call(@name, :get_sensor_data)
  end

  def set_refresh_interval(time) do
    GenServer.cast(@name, {:set_interval, time})
  end

  # SERVER CALLBACK FUNCTIONS
  # we are ignoring state (the empty map passed by start()) because we want to override it with other values
  def init(state) do
    initial_state = run_task_get_sensor_data()

    new_state = %{
      state
      | sensor_data: initial_state
    }

    IO.inspect(new_state)

    sched_refresh(state.interval)
    {:ok, new_state}
  end

  def handle_cast({:set_interval, time}, state) do
    new_state = %{state | interval: :timer.seconds(time)}
    {:noreply, new_state}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:refresh, state) do
    IO.puts("refreshing state...")
    new_sensor_data = run_task_get_sensor_data()
    new_state = %{state | sensor_data: new_sensor_data}
    sched_refresh(state.interval)

    {:noreply, new_state}
  end

  defp sched_refresh(interval) do
    # *** We want the state of this server to be updated every hour with new locations & snapshots
    # *** to do this we need to have this server send a :refresh message to itself every 60 mins. When that msg is resolved, it will then schedule another one

    # send_after takes 3 args--pid to send to, message, how long to wait to send msg
    Process.send_after(self(), :refresh, interval)
  end

  defp run_task_get_sensor_data do
    # list of animals
    animal_locations =
      ["animal1", "animal2", "animal3", "animal4", "animal5"]
      |> Enum.map(&Task.async(fn -> Servy.Tracker.get_location(&1) end))
      # get msg for each PID that is returned by Task.async
      |> Enum.map(&Task.await(&1))

    # Task.async(fun) and Task.await(task) are the built in versions of our Fetch.asynch(fun) and Fetch.get_msg(pid)
    # animal1_task_struct = Task.async(fn -> Servy.Tracker.get_location("animal1") end)
    # animal_location = Task.await(animal1_task_struct)

    # list of camera names
    snapshots =
      ["cam1", "cam2", "cam3", "cam4", "cam5"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      # get msg for each PID that is returned by Fetch.asynch(fun)
      |> Enum.map(&Task.await(&1))

    %{snapshots: snapshots, animal_locations: animal_locations}
  end
end
