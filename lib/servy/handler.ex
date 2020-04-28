defmodule Servy.Handler do
  @moduledoc "handle http request"
  alias Servy.Conv
  alias Servy.BearController

  @pages_dir_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  def handle(request) do
    request
    |> parse
    # this will catch any extraneous requests we still want to serve
    |> rewrite_path
    |> log
    |> route
    # Every time we get a 404, lets log the missing path
    |> track
    |> emojify
    |> format_response
  end

  '''
  ROUTE FUNCTIONS
  '''

  # step 8
  # to catch any other requests that we want to serve /wildthings we need to catch the request before
  # it hits route in the main pipline!
  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    BearController.index(conv)
  end

  # bears route
  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    %{conv | status: 200, resp_body: "Brown, Black, Moon"}
  end

  # lions route
  def route(%Conv{method: "GET", path: "/lions"} = conv) do
    %{conv | status: 200, resp_body: "leo, Ghost, Darkness"}
  end

  # read file form using CASE
  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_dir_path
    # we then need to concatenate the path with the file name
    |> Path.join("form.html")
    # File.read will return a tuple
    |> File.read()
    # tuple will be first(not visible) arg, conv map second.
    |> handle_file(conv)
  end

  # read about file
  def route(%Conv{method: "GET", path: "/about"} = conv) do
    # we need to get absolute file path to the directory that our file is in.
    # this means we need the ABS path to the "/pages" directory. So, we use the Path.expand function
    # on the path to "pages" relative to this file's loction
    # Path.expand expands the first argument/path relative to the second argument

    Path.expand("../../pages", __DIR__)
    # we then need to concatenate the path with the file name
    |> Path.join("about.html")
    # File.read will return a tuple
    |> File.read()
    # tuple will be first(not visible) arg, conv map second.
    |> handle_file(conv)
  end

  # route for pattern matching specific animal ex. "bears/1"
  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  # route for pattern matching DELETE request"
  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.delete(conv, params)
  end

  # POST route for new bear
  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    # need to also send the posted params
    BearController.create(conv, conv.params)
  end

  # 404 route. Catch-all routes should be declared LAST in order!
  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} Found!"}
  end

  '''
  EMOJI FUNCTIONS
  '''

  def emojify(%Conv{status: 200, resp_body: resp_body} = conv) do
    %{conv | resp_body: "-----> " <> resp_body <> " <-----"}
  end

  def emojify(conv), do: conv

  '''
  FORMAT_RESPONSE FUNCTION
  '''

  def format_response(%Conv{} = conv) do
    # {conv.protocol} #{conv.status} #{status_reason(conv.status)}
    """
    #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

# -------------first request--------------

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: exampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# -------------second request--------------

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: exampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# -------------third request--------------

# request = """
# GET /lions HTTP/1.1
# Host: example.com
# User-Agent: exampleBrowser/1.0
# Accept: */*

# """

# response = Servy.Handler.handle(request)
# IO.puts(response)

# -------------Bad request--------------

# request = """
# GET /wolf HTTP/1.1
# Host: example.com
# User-Agent: exampleBrowser/1.0
# Accept: */*

# """

# response = Servy.Handler.handle(request)
# IO.puts(response)

# -------------specific bear request--------------

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: exampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# -------------specific bear request--------------

# request = """
# DELETE /bears/1 HTTP/1.1
# Host: example.com
# User-Agent: exampleBrowser/1.0
# Accept: */*

# """

# response = Servy.Handler.handle(request)
# IO.puts(response)

# -------------TRANSFORMATION request--------------
# to do this we will need to pattern match on a map

# in this case we want the request for "wildlife" to be handled by the
# function that catches "/wildthings"

# request = """
# GET /wildlife HTTP/1.1
# Host: example.com
# User-Agent: exampleBrowser/1.0
# Accept: */*

# """

# response = Servy.Handler.handle(request)
# IO.puts(response)

# -------------test rewrite request--------------

# request = """
# GET /bears?id=1 HTTP/1.1
# Host: example.com
# User-Agent: exampleBrowser/1.0
# Accept: */*

# """

# response = Servy.Handler.handle(request)
# IO.puts(response)

# -------------Read file request--------------

# request = """
# GET /about HTTP/1.1
# Host: example.com
# User-Agent: exampleBrowser/1.0
# Accept: */*

# """

# response = Servy.Handler.handle(request)
# IO.puts(response)

# -------------Read Form page request--------------

# request = """
# GET /bears/new HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# response = Servy.Handler.handle(request)
# IO.puts(response)

# -------------Mock POST request--------------
request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Smokey&type=Brown
"""

response = Servy.Handler.handle(request)

IO.puts(response)
