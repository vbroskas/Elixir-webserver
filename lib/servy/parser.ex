defmodule Servy.Parser do
  '''
  PARSE
  '''

  def parse(request) do
    [method, path, version] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    IO.puts("Initial Path is..." <> path)

    # dont need field for status & resp_body because they are defined in the struct definition in conv.ex
    %Servy.Conv{method: method, path: path, version: version}
  end
end
