defmodule Servy.Plugins do
  alias Servy.Conv

  '''
  REWRITE_PATH
  '''

  # special case function clause to catch "/wildlife"
  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  # Regex rewrite_path function
  def rewrite_path(%Conv{path: path} = conv) do
    # basic regex: ~r{\/(\w+)\?id=(\d+)} ----- matches "/"" + 1 or more written chars + "?id="" + 1 or more digits
    # regex to capture variables: ~r{\/(?<thing>\w+)\?id=(?<id>\d+)} ----- matches thing to the 1 or more written chars
    # and matches id to the 1 or more digits

    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    # Regex.named_captures returns a map with {"thing"=>thing, "id"=>id}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(%Conv{} = conv, %{"thing" => thing, "id" => id}) do
    %{conv | path: "/#{thing}/#{id}"}
  end

  def rewrite_path_captures(%Conv{} = conv, nil), do: conv

  '''
  LOG
  '''

  # SINGLE LINE FUNC, this will print the map
  def log(%Conv{} = conv) do
    if Mix.env() == :dev do
      IO.inspect(conv)
    end

    conv
  end

  '''
  TRACK FUNCTIONS
  '''

  # this function will match a 404 status code and extract the path
  def track(%Conv{status: 404, path: path} = conv) do
    if Mix.env() != :test do
      IO.puts("Warning we have found a new path: #{path}")
    end

    conv
  end

  # default track function
  def track(%Conv{} = conv), do: conv
end
