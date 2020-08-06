defmodule Servy.KickStarter do
  use GenServer

  def get_server() do
    GenServer.call(__MODULE__, :get_server_pid)
  end

  # *** we need a way for kickstarter to moniter the http_server process to know if it crashes
  def start do
    IO.puts("Starting kickstarter server")
    GenServer.start(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # trap all exit signals sent when our http_server crashes. **if we don't trap exists with the linked process, then when one process crashes, they both will!!**
    Process.flag(:trap_exit, true)
    http_server_pid = start_http_server()
    {:ok, http_server_pid}
  end

  def handle_call(:get_server_pid, state) do
    {:reply, state, state}
  end

  # This handle info is used to catch when our HTTP server crashes
  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("Http server died for reason: #{inspect(reason)}")
    http_server_pid = start_http_server()
    {:noreply, http_server_pid}
  end

  defp start_http_server do
    IO.puts("starting HTTP server")

    # using spawn_link is better than spawning and then linking in two seperate steps (avoids and race conditions)
    http_server_pid = spawn_link(Servy.HttpServer, :start, [4000])

    # because we call link from within the kickstarter process (we're in the kickstarter init), it is now linked to the http_server process
    Process.register(http_server_pid, :http_server)
    http_server_pid
  end
end
