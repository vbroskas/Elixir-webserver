defmodule Servy.Fetch do
  # pass in any function name we want to spawn a process with
  def async(fun) do
    parent = self()

    # we include the spawned process' PID --using self()-- so we can use it to match for the correct message we want, since we cant depend on the order messages are.
    # spawn() returns
    spawn(fn -> send(parent, {self(), :result, fun.()}) end)
  end

  def get_msg(pid) do
    # once process has been spawned, we will call receive and wait for the msg to arrive

    receive do
      # we use the pin operator here to check that the passed in pid matches the variables exisiting value, NOT binding it to a new value
      {^pid, :result, value} ->
        value
    end
  end
end
