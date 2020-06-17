defmodule Servy.Timer do
  def remind(message, delay) do
    delay = delay * 1000

    spawn(fn ->
      :timer.sleep(delay)
      IO.puts(message)
    end)
  end
end
