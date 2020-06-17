defmodule Servy.HttpServer do
  @doc """
  starts our server on localhost port
  in IEX call: Servy.HttpServer.start(4000) to start mock server
  """

  # ports 0 - 1023 are reserved for the operating system!
  def start(port) when is_integer(port) and port > 1023 do
    # calling :gen_tcp.listen, creates socket to listen for client connections
    # listen_socket will be bound to the listening socket

    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    # socket options:
    # :binary - open the socket in binary mode and deliver data as binaries
    # packet: :raw - deliver the entire binary without any packet handling
    # active: false - receive data when ready by calling :gen_tcp.recv/2
    # reuseaddr: true allows reusing the address if the listener crashes

    IO.puts("\n Listening for a connection request on port #{port}...\n")

    accept_loop(listen_socket)
  end

  @doc """
  accepts client connections on the listen_socket
  """
  def accept_loop(listen_socket) do
    IO.puts("Waiting to accept a client connection......\n")

    # :gen_tcp.accept suspends/blocks and waits for a client connection. When a connection is accpeted, client_socket is bound to a new client socket
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)
    IO.puts("connection has been accepted")

    # receives request and sends a response over the client socket
    # we're using spawn to run the serve process asynchronously
    spawn(fn -> serve(client_socket) end)

    # loop back to wait for next connection
    accept_loop(listen_socket)
  end

  @doc """
  receives request on the client socket and
  sends a response back over that same socket
  """
  def serve(client_socket) do
    # self() return the PID of the current process. inspect formats it nicely
    IO.puts("#{inspect(self())}: Working....")

    client_socket
    # returns request as a string
    |> read_request
    # returns response as a string
    |> Servy.Handler.handle()
    # takes response string and sends it back out over client socket
    |> write_response(client_socket)
  end

  @doc """
  receives a request on the client socket and returns request as a string
  """
  def read_request(client_socket) do
    # using zero denotes get all available bytes
    {:ok, request} = :gen_tcp.recv(client_socket, 0)

    IO.puts("-- received request!: \n")
    IO.puts(request)

    request
  end

  @doc """
  returns a generic HTTP response
  """
  def generate_response(_request) do
    """
    HTTP/1.1 200 OK\r
    Content-Type: text/plain\r
    Content-Length: 6\r
    \r
    Hello!
    """
  end

  @doc """
  sends the response over the client_socket
  """
  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)

    IO.puts("-- sent response!")
    IO.puts(response)

    # close out the client socket ending the connection
    # this DOES NOT close the listen socket!
    :gen_tcp.close(client_socket)
  end

  # def server()do
  #   {:ok, lsock} = :gen_tcp.listen(5678, [:binary, packet: 0, active: false])
  #   {:ok, sock} = :gen_tcp.accept(lsock)socket

  #   # send valid http response back to client, and then loop back up to request line to wait for next request

  #   # close client socket
  #   :ok = :gen_tcp.close(sock)

  #   bin
  # end
end
