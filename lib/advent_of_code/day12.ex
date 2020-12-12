defmodule AdventOfCode.Day12 do
  @doc ~S"""
  ## Examples

      iex> part1("F10\nN3\nF7\nR90\nF11")
      25

      iex> part2("F10\nN3\nF7\nR90\nF11")
      286

  """
  def part1(input) do
    parse_input(input)
    |> Enum.reduce({:east, 0, 0}, &move/2)
    |> (fn {_, x, y} -> abs(x) + abs(y) end).()
  end

  def part2(input) do
    parse_input(input)
    |> Enum.reduce({0, 0, 10, -1}, &move2/2)
    |> (fn {x, y, _, _} -> abs(x) + abs(y) end).()
  end

  defp parse_input(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(fn
      "N" <> amount -> {:north, String.to_integer(amount)}
      "S" <> amount -> {:south, String.to_integer(amount)}
      "E" <> amount -> {:east, String.to_integer(amount)}
      "W" <> amount -> {:west, String.to_integer(amount)}
      "L" <> amount -> {:left, String.to_integer(amount)}
      "R" <> amount -> {:right, String.to_integer(amount)}
      "F" <> amount -> {:forward, String.to_integer(amount)}
    end)
  end

  defp move({:left, 90}, {:north, x, y}), do: {:west, x, y}
  defp move({:left, 90}, {:west, x, y}), do: {:south, x, y}
  defp move({:left, 90}, {:south, x, y}), do: {:east, x, y}
  defp move({:left, 90}, {:east, x, y}), do: {:north, x, y}
  defp move({:left, 180}, {:north, x, y}), do: {:south, x, y}
  defp move({:left, 180}, {:west, x, y}), do: {:east, x, y}
  defp move({:left, 180}, {:south, x, y}), do: {:north, x, y}
  defp move({:left, 180}, {:east, x, y}), do: {:west, x, y}
  defp move({:left, 270}, {:north, x, y}), do: {:east, x, y}
  defp move({:left, 270}, {:west, x, y}), do: {:north, x, y}
  defp move({:left, 270}, {:south, x, y}), do: {:west, x, y}
  defp move({:left, 270}, {:east, x, y}), do: {:south, x, y}
  defp move({:right, 90}, {:north, x, y}), do: {:east, x, y}
  defp move({:right, 90}, {:west, x, y}), do: {:north, x, y}
  defp move({:right, 90}, {:south, x, y}), do: {:west, x, y}
  defp move({:right, 90}, {:east, x, y}), do: {:south, x, y}
  defp move({:right, 180}, {:north, x, y}), do: {:south, x, y}
  defp move({:right, 180}, {:west, x, y}), do: {:east, x, y}
  defp move({:right, 180}, {:south, x, y}), do: {:north, x, y}
  defp move({:right, 180}, {:east, x, y}), do: {:west, x, y}
  defp move({:right, 270}, {:north, x, y}), do: {:west, x, y}
  defp move({:right, 270}, {:west, x, y}), do: {:south, x, y}
  defp move({:right, 270}, {:south, x, y}), do: {:east, x, y}
  defp move({:right, 270}, {:east, x, y}), do: {:north, x, y}
  defp move({:forward, amount}, {:north, x, y}), do: {:north, x, y - amount}
  defp move({:forward, amount}, {:east, x, y}), do: {:east, x + amount, y}
  defp move({:forward, amount}, {:south, x, y}), do: {:south, x, y + amount}
  defp move({:forward, amount}, {:west, x, y}), do: {:west, x - amount, y}
  defp move({:north, amount}, {dir, x, y}), do: {dir, x, y - amount}
  defp move({:east, amount}, {dir, x, y}), do: {dir, x + amount, y}
  defp move({:south, amount}, {dir, x, y}), do: {dir, x, y + amount}
  defp move({:west, amount}, {dir, x, y}), do: {dir, x - amount, y}

  defp move2({:left, 90}, {x, y, wx, wy}), do: {x, y, wy, -wx}
  defp move2({:left, 180}, {x, y, wx, wy}), do: {x, y, -wx, -wy}
  defp move2({:left, 270}, {x, y, wx, wy}), do: {x, y, -wy, wx}
  defp move2({:right, 90}, {x, y, wx, wy}), do: {x, y, -wy, wx}
  defp move2({:right, 180}, {x, y, wx, wy}), do: {x, y, -wx, -wy}
  defp move2({:right, 270}, {x, y, wx, wy}), do: {x, y, wy, -wx}
  defp move2({:north, amount}, {x, y, wx, wy}), do: {x, y, wx, wy - amount}
  defp move2({:east, amount}, {x, y, wx, wy}), do: {x, y, wx + amount, wy}
  defp move2({:south, amount}, {x, y, wx, wy}), do: {x, y, wx, wy + amount}
  defp move2({:west, amount}, {x, y, wx, wy}), do: {x, y, wx - amount, wy}
  defp move2({:forward, amount}, {x, y, wx, wy}), do: {x + wx * amount, y + wy * amount, wx, wy}
end
