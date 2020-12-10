defmodule AdventOfCode.Day10 do
  @doc ~S"""
  ## Examples

      iex> part1("16\n10\n15\n5\n1\n11\n7\n19\n6\n12\n4")
      35

      iex> part1("28\n33\n18\n42\n31\n14\n46\n20\n48\n47\n24\n23\n49\n45\n19\n38\n39\n11\n1\n32\n25\n35\n8\n17\n7\n9\n4\n2\n34\n10\n3")
      220

      iex> part2("16\n10\n15\n5\n1\n11\n7\n19\n6\n12\n4")
      8

      iex> part2("28\n33\n18\n42\n31\n14\n46\n20\n48\n47\n24\n23\n49\n45\n19\n38\n39\n11\n1\n32\n25\n35\n8\n17\n7\n9\n4\n2\n34\n10\n3")
      19208

  """
  def part1(input) do
    parse_input(input)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> b - a end)
    |> Enum.frequencies()
    |> Enum.map(fn {a, count} -> {a, count + 1} end)
    |> Map.new()
    |> (fn %{1 => one, 3 => three} -> one * three end).()
  end

  def part2(input) do
    parse_input(input)
    |> count_arrangements()
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort()
  end

  defp count_arrangements(adapters) do
    adapters = List.insert_at(adapters, 0, 0)
    ways = Enum.map(adapters, fn _ -> 0 end) |> List.replace_at(0, 1)

    populate_ways(adapters, ways)
    |> List.last()
  end

  defp populate_ways(adapters, ways, i \\ 0)
  defp populate_ways(_, ways, i) when length(ways) <= i, do: ways

  defp populate_ways(adapters, ways, i) do
    (i - 3)..(i - 1)
    |> Enum.filter(fn j -> j >= 0 end)
    |> Enum.reduce(ways, fn j, ways ->
      if Enum.at(adapters, i) <= Enum.at(adapters, j) + 3 do
        (Enum.at(ways, i) + Enum.at(ways, j))
        |> (&List.replace_at(ways, i, &1)).()
      else
        ways
      end
    end)
    |> (&populate_ways(adapters, &1, i + 1)).()
  end
end
