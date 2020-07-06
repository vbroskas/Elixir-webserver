defmodule Servy.KickStarter do
  use GenServer

  # *** we need a way for kickstarter to moniter the http_server process to know if it crashes

  def start do
    IO.puts("Starting kickstarter server")
    GenServer.start(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # trap all exit signals sent when our http_server crashes
    Process.flag(:trap_exit, true)
    http_server_pid = start_http_server()
    {:ok, http_server_pid}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("Http server died for reason: #{inspect(reason)}")
    http_server_pid = start_http_server()
    {:noreply, http_server_pid}
  end

  defp start_http_server do
    IO.puts("starting HTTP server")
    http_server_pid = spawn_link(Servy.HttpServer, :start, [4000])

    # because we call link from within the kickstarter process (we're in the kickstarter init), it is now linked to the http_server process

    Process.register(http_server_pid, :http_server)
    http_server_pid
  end
end
