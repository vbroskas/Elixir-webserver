defmodule Servy.Parser do
  alias Servy.Conv

  '''
  PARSE
  '''

  # request = """
  #   POST /bears HTTP/1.1
  #   Host: example.com
  #   User-Agent: ExampleBrowser/1.0
  #   Accept: */*
  #   Content-Type: application/x-www-form-urlencoded
  #   Content-Length: 21

  #   name=Smokey&type=Brown
  # """

  def parse(request) do
    # ultimately we want to split up the incoming request into 3 main parts:
    # 1- the very top line with request type (POST, GET, etc) the path and the protocol
    # 2- all the following lines EXCEPT the very last params line
    # 3- the last line which is the params string

    # first we split the request on a double newline (\n\n) which seperates the bottom line (params) from everything above it - returns list with 2 elements which we can pattern match on
    [top, params_string] = String.split(request, "\n\n")

    [request_line | header_lines] = String.split(top, "\n")

    # split request_line and pattern match variables to it
    [method, path, protocol] = String.split(request_line, " ")

    # put headers into map
    headers = parse_headers(header_lines, %{})

    params = parse_params(params_string)
    IO.inspect(headers)

    # dont need field for status & resp_body because they are defined in the struct definition in conv.ex
    %Conv{method: method, path: path, protocol: protocol, params: params, headers: headers}
  end

  '''
  function to decode params
  '''

  def parse_params(params_string) do
    # first - trim newline off string
    # second - run decode query which will return a map of the params
    params_string |> String.trim() |> URI.decode_query()
  end

  '''
  parse headers & add into map
  '''

  def parse_headers([head | tail], headers) do
    # for each head we need to parse into key/value string
    [key, value] = String.split(head, ": ")

    # add k/v pairs to headers map
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  '''
  parse headers termination case, just return headers map
  '''

  def parse_headers([], headers) do
    headers
  end
end
