# --------------GenServer MODULE--------------------------------

# defmodule Servy.GenServer do
#   def start(callback_module, initial_state, loop_process_name) do
#     # This function is called by the client to start the server process
#     # __MODULE__ just references this module where we can find listen_loop()
#     pid = spawn(__MODULE__, :counter_loop, [callback_module, initial_state])
#     Process.register(pid, loop_process_name)
#     IO.puts("GenServer server started...")
#   end

#   # remote procedure call, a synchronous request. GenServer function for making requets to our server process(loop)
#   # a helper function for all synchronous requests (sending and receiving a msg)
#   def call(recipient, message) do
#     # *** recipient USED to be @name when call had access to @name before we move this function into a GenServer module. Since call() is
#     # now a GenServer function we must pass the @name to call from the client functions
#     send(recipient, {:call, self(), message})

#     receive do
#       {:response, response} ->
#         response
#     end
#   end

#   # this is an asynchronous request. it sends a msg to the server and doesn't wait for a reply back
#   def cast(recipient, message) do
#     send(recipient, {:cast, self(), message})
#   end

#   def counter_loop(callback_module, counter) do
#     receive do
#       # call that expects response
#       # callback_module represents whatever specific module is using our GenServer server. In this case it represents Servy.FourOhFourCounter
#       {:call, sender, message} ->
#         {response, counter} = callback_module.handle_call(message, counter)
#         send(sender, {:response, response})
#         counter_loop(callback_module, counter)

#       # no response expected
#       {:cast, message} ->
#         {_response, counter} = callback_module.handle_call(message, counter)
#         counter_loop(callback_module, counter)

#       unknown ->
#         IO.puts("Unknow input: #{unknown}")
#         counter_loop(callback_module, counter)
#     end
#   end
# end

defmodule Servy.FourOhFourCounter do
  @name :four_oh_four_server

  use GenServer

  defmodule State do
    defstruct four_oh_fours: %{}
  end

  # --------------CLIENT INTERFACE FUNCTIONS --------------------------------
  def start_link(_args) do
    IO.puts("Starting 404 counter via GenServer server...")
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def four_oh_four_found(path) do
    GenServer.call(@name, {:hit, path})
  end

  def get_count(path) do
    GenServer.call(@name, {:get_count, path})
  end

  def get_counts() do
    GenServer.call(@name, :get_counts)
  end

  # ---------------SERVER CALLBACKS------------------

  def init(state) do
    # assuming we cache all our 404 in an outside service or DB, we could grab them here
    current_state = get_current_404()
    updated_state = Map.merge(state, current_state)
    {:ok, updated_state}
  end

  # get counts
  def handle_call(:get_counts, _from, state) do
    {:reply, state, state}
  end

  # get count
  def handle_call({:get_count, path}, _from, state) do
    count = Map.get(state, path)
    {:reply, count, state}
  end

  # 404 found
  def handle_call({:hit, path}, _from, state) do
    new_state = Map.update(state, path, 1, &(&1 + 1))
    {:reply, :ok, new_state}
  end

  def handle_info(message, state) do
    IO.puts("Bad msg sent: #{inspect(message)}")
    {:noreply, state}
  end

  defp get_current_404() do
    %{"/firstBad" => 3, "/secondBad" => 1}
  end
end
