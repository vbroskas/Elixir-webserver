defmodule Recurse do
  def sum([head | tail], total) do
    IO.puts("Total: #{total} Head: #{head} Tail: #{inspect(tail)}")
    sum(tail, total + head)
  end

  def sum([], total), do: total

  def triple([head | tail], current_list) do
    triple(tail, [head * 3 | current_list])
  end

  def triple([], current_list) do
    current_list |> Enum.reverse()
  end
end

IO.inspect(Recurse.triple([1, 2, 3, 4, 5], []))
