defmodule Servy.GenericServer do
  # --------GENERIC HELPER FUNCTIONS---------------------------------
  def start(callback_module, initial_state, name) do
    # This function is called by the client to start the server process
    pid = spawn(__MODULE__, :listen_loop, [callback_module, initial_state])
    Process.register(pid, name)
    pid
  end

  # remote procedure call, a synchronous request. generic function for making requets to our server process(loop)
  # a helper function for all synchronous requests (sending and receiving a msg)
  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    end
  end

  # this is an asynchronous request. it sends a msg to the server and doesn't wait for a reply back
  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  def listen_loop(callback_module, cache) do
    # modules in elixir CANT hold state, however processes can, so we need to store our cache in a process
    # https://online.pragmaticstudio.com/courses/elixir/modules/24 @ 6.22
    IO.puts("\nWaiting for msg...")

    receive do
      {:call, sender, message} when is_pid(sender) ->
        # callback_module represents whatever specific module is using our generic server. In this case it represents Servy.PledgeServer
        {response, cache} = callback_module.handle_call(message, cache)
        # send response to sender
        send(sender, {:response, response})
        # call listen_loop
        listen_loop(callback_module, cache)

      # asynch request for clearing cache
      {:cast, message} ->
        cache = callback_module.handle_cast(message, cache)
        listen_loop(callback_module, cache)

      # catch all other messages. If we don't catch them, all other msgs will build up in the processes mailbox
      unexpected ->
        IO.puts("Unknown msg: #{inspect(unexpected)}")
        listen_loop(callback_module, cache)
    end
  end
end

defmodule Servy.PledgeServer do
  # The functions in this module each run in different processes
  @name :pledge_server
  alias Servy.GenericServer

  # -------FUNCTIONS CALLED BY CLIENT PROCESS----------------------
  def start do
    # This function is called by the client to start the server process
    IO.puts("Starting pledge server...")

    # using __MODULE__ here is saying that this module (Servy.PledgeServer) is the callback module to be used whenever our generic server sends messages back
    GenericServer.start(__MODULE__, [], @name)
  end

  def clear do
    GenericServer.cast(@name, :clear)
  end

  def create_pledge(name, amount) do
    GenericServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges() do
    GenericServer.call(@name, :recent_pledges)
  end

  def total_pledged do
    GenericServer.call(@name, :total_pledged)
  end

  # -------SPAWNED SERVER PROCESS FUNCTIONS----------------------

  def handle_cast(message, _cache) do
    []
  end

  # get total amount pledged
  def handle_call(:total_pledged, cache) do
    # calculate total of pledges
    total = Enum.reduce(cache, 0, fn {_name, amount}, acc -> acc + amount end)
    {total, cache}
  end

  # get 3 most recent pledges
  def handle_call(:recent_pledges, cache) do
    # calculate total of pledges
    recent_pledges = Enum.take(cache, 3)
    {recent_pledges, cache}
  end

  # get 3 most recent pledges
  def handle_call({:create_pledge, name, amount}, cache) do
    # send pledge transation to outside service
    {:ok, transaction_id} = send_pledge_to_service(name, amount)
    # add pledge to local cache
    cache = [{name, amount} | cache]
    {transaction_id, cache}
  end

  def handle_call(:clear, cache) do
  end

  defp send_pledge_to_service(_name, _amount) do
    # send pledge to external service...
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

# THIS MOCK SECTION IS PLAYING THE PART OF OUR CLIENT PROCESS

alias Servy.PledgeServer

# # SERVER PROCESS PID
pid = PledgeServer.start()
send(pid, {:stop, "poips"})

IO.inspect(PledgeServer.create_pledge("joe", 5))
IO.inspect(PledgeServer.create_pledge("ted", 10))
IO.inspect(PledgeServer.create_pledge("moe", 15))
IO.inspect(PledgeServer.create_pledge("bob", 20))
IO.inspect(PledgeServer.create_pledge("sam", 25))
IO.inspect(PledgeServer.create_pledge("cue", 30))

PledgeServer.clear()

# IO.puts("\n-----------------------------")
IO.inspect(PledgeServer.recent_pledges())
IO.inspect(PledgeServer.total_pledged())
