defmodule Servy.PledgeServer do
  @name :pledge_server
  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  # -------FUNCTIONS CALLED BY CLIENT PROCESS----------------------
  def start do
    # This function is called by the client to start the server process
    IO.puts("Starting pledge server...")

    # using __MODULE__ here is saying that this module (Servy.PledgeServer) is the callback module to be used whenever our generic server sends messages back
    # INIT: when start is called, the second arg here (%State{}) will be passed to init(). **start() will block until init() returns!!!**
    GenServer.start(__MODULE__, %State{}, name: @name)
  end

  def clear do
    GenServer.cast(@name, :clear)
  end

  def create_pledge(name, amount) do
    GenServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges() do
    GenServer.call(@name, :recent_pledges)
  end

  def total_pledged do
    GenServer.call(@name, :total_pledged)
  end

  def set_cache_size(size) do
    GenServer.cast(@name, {:set_cache_size, size})
  end

  # -------SPAWNED SERVER PROCESS CALLBACKS----------------------

  def init(state) do
    # state is initially our default struct
    # grab new pledges from outside service, and have init() return the new state to the start() function
    pledges = fetch_recent_pledges_from_service()
    new_state = %{state | pledges: pledges}
    {:ok, new_state}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end

  def handle_cast({:set_cache_size, size}, state) do
    new_state = %{state | cache_size: size}
    {:noreply, new_state}
  end

  # from is required by GenServer and is some information about the sender
  def handle_call(:total_pledged, _from, state) do
    # calculate total of pledges
    total = Enum.reduce(state.pledges, 0, fn {_name, amount}, acc -> acc + amount end)
    # :reply indicates that the server should reply to the client
    {:reply, total, state}
  end

  # get 3 most recent pledges
  def handle_call(:recent_pledges, _from, state) do
    # calculate total of pledges
    recent_pledges = Enum.take(state.pledges, state.cache_size)
    {:reply, recent_pledges, state}
  end

  # get 3 most recent pledges
  def handle_call({:create_pledge, name, amount}, _from, state) do
    # send pledge transation to outside service
    {:ok, transaction_id} = send_pledge_to_service(name, amount)
    # add pledge to pledges list
    new_pledges = [{name, amount} | state.pledges]
    new_state = %{state | pledges: new_pledges}
    {:reply, transaction_id, new_state}
  end

  # handle_info in GenServer is used to handle any messages that aren't sent using call() or cast()
  # you have to override it if you want custom behavior
  def handle_info(message, state) do
    IO.puts("ERRORRR at: #{inspect(message)}")
    {:noreply, state}
  end

  defp send_pledge_to_service(_name, _amount) do
    # send pledge to external service...
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service() do
    # grab all pledges from our external caching service

    [{"buddy", 44}, {"teddy", 77}]
  end
end

# THIS MOCK SECTION IS PLAYING THE PART OF OUR CLIENT PROCESS

alias Servy.PledgeServer

# # SERVER PROCESS PID
# {:ok, pid} = PledgeServer.start()
# send(pid, {:stop, "poips"})

# IO.inspect(PledgeServer.create_pledge("joe", 5))
# IO.inspect(PledgeServer.create_pledge("ted", 110))
# # IO.inspect(PledgeServer.create_pledge("moe", 15))
# # IO.inspect(PledgeServer.create_pledge("bob", 250))
# # IO.inspect(PledgeServer.create_pledge("sam", 25))
# # IO.inspect(PledgeServer.create_pledge("cue", 390))

# # PledgeServer.clear()

# PledgeServer.set_cache_size(4)
# IO.inspect(PledgeServer.recent_pledges())
# IO.inspect(PledgeServer.total_pledged())
