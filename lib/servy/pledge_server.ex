defmodule Servy.PledgeServer do
  # The functions in this module each run in different processes
  @name :pledge_server

  # -------FUNCTIONS CALLED BY CLIENT PROCESS----------------------
  def start do
    # This function is called by the client to start the server process
    IO.puts("Starting pledge server...")
    pid = spawn(__MODULE__, :listen_loop, [])
    Process.register(pid, @name)
    pid
  end

  def create_pledge(name, amount) do
    # THIS WILL RUN IN THE CLIENT PROCESS. Whatever process calls this function needs to send it's PID so we know who made the request.
    # send a message to our server process
    send(@name, {self(), :create_pledge, name, amount})

    receive do
      {:response, status} -> status
    end
  end

  def recent_pledges() do
    # things to keep in mind...
    # sending a message is always asynchronous
    # receive is a blocking call...receive will wait for a response from the server
    # because we have both a send() and receive() in this function, that makes this function synchronous because it gets held up by receive

    # using self() here denotes we want the message sent back to this functions process
    send(@name, {self(), :recent_pledges})

    receive do
      {:response, cache} -> cache
    end
  end

  def total_pledged do
    # will send request to server process for total amount pledged. it expects a reply back
    send(@name, {self(), :total_pledged})

    # receive msg back from server process with total_pledged
    receive do
      {:response, total} -> total
    end
  end

  # remote procedure call, a synchronous request. generic function for making requets to our server process(loop)
  def call(pid, message) do
    send(pid, {self(), message})

    receive do
      {:response, response} -> response
    end
  end

  # -------SPAWNED SERVER PROCESS FUNCTIONS----------------------
  def listen_loop(cache \\ []) do
    # modules in elixir CANT hold state, however processes can, so we need to store our cache in a process
    # https://online.pragmaticstudio.com/courses/elixir/modules/24 @ 6.22
    IO.puts("\nWaiting for msg...")

    receive do
      # create new pledge
      {sender, :create_pledge, name, amount} ->
        # send pledge transation to outside service
        {:ok, transaction_id} = send_pledge_to_service(name, amount)
        # add pledge to local cache
        cache = [{name, amount} | cache]
        # send msg back to sender with ID of transation (or error)
        send(sender, {:response, transaction_id})
        IO.puts("#{name} pledged #{amount}")
        IO.puts("cache is...#{inspect(cache)}")
        # keep listen_loop running
        listen_loop(cache)

      # get 3 recent pledges
      {sender, :recent_pledges} ->
        # the sender(senders pid) comes from the client process who is requesting the cache. we need to send the cache back to sender
        # only send back the most recent 3 entries
        send(sender, {:response, Enum.take(cache, 3)})
        IO.puts("\nSend cache to #{inspect(sender)}!!!")
        listen_loop(cache)

      # get total amount pledged
      {sender, :total_pledged} ->
        # calculate total of pledges
        total = Enum.reduce(cache, 0, fn {_name, amount}, acc -> acc + amount end)
        send(sender, {:response, total})
        listen_loop(cache)

      # catch all other messages. If we don't catch them, all other msgs will build up in the processes mailbox
      unexpected ->
        IO.puts("Unknown msg: #{inspect(unexpected)}")
        listen_loop()
    end
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

IO.inspect(PledgeServer.create_pledge("joe", 5))
IO.inspect(PledgeServer.create_pledge("ted", 10))
IO.inspect(PledgeServer.create_pledge("moe", 15))
IO.inspect(PledgeServer.create_pledge("bob", 20))
IO.inspect(PledgeServer.create_pledge("sam", 25))
IO.inspect(PledgeServer.create_pledge("cue", 30))

# IO.puts("\n-----------------------------")
IO.inspect(PledgeServer.recent_pledges())
IO.inspect(PledgeServer.total_pledged())
