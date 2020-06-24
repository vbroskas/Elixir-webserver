defmodule Servy.FourOhFourCounter do
  @name :counter

  def start do
    IO.puts("Starting 404 counter...")
    # first spawn a server process and get the PID for it
    pid = spawn(__MODULE__, :counter_loop, [%{}])
    # register that pid with the name we defined at top (:counter)
    Process.register(pid, @name)
    IO.puts("THERE")
  end

  def four_oh_four_found(path) do
    # send message to counter_loop()
    send(@name, {self(), :hit, path})
    # get msg sent back
    receive do
      {:response, value} ->
        value
    end
  end

  def get_count(path) do
    # send msg to counter_loop()
    send(@name, {self(), :get_count, path})
    # get response msg
    receive do
      {:response, value} ->
        value
        # code
    end
  end

  def get_counts() do
    # send msg to counter_loop()
    send(@name, {self(), :get_counts})
    # get response msg
    receive do
      {:response, value} ->
        value
        # code
    end
  end

  def counter_loop(counter \\ %{}) do
    receive do
      # increase 404 count
      {sender, :hit, path} ->
        counter = Map.update(counter, path, 1, &(&1 + 1))
        # send msg back to four_oh_four_found()
        send(sender, {:response, "done"})
        # keep counter_loop()  running
        counter_loop(counter)

      {sender, :get_count, path} ->
        send(sender, {:response, Map.get(counter, path)})
        counter_loop(counter)

      {sender, :get_counts} ->
        send(sender, {:response, counter})
        counter_loop(counter)
    end
  end
end
