defmodule AdventOfCode.Day07 do
  @doc ~S"""
  ## Examples

      iex> AdventOfCode.Day07.part1("light red bags contain 1 bright white bag, 2 muted yellow bags.\ndark orange bags contain 3 bright white bags, 4 muted yellow bags.\nbright white bags contain 1 shiny gold bag.\nmuted yellow bags contain 2 shiny gold bags, 9 faded blue bags.\nshiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.\ndark olive bags contain 3 faded blue bags, 4 dotted black bags.\nvibrant plum bags contain 5 faded blue bags, 6 dotted black bags.\nfaded blue bags contain no other bags.\ndotted black bags contain no other bags.")
      4

      iex> AdventOfCode.Day07.part2("light red bags contain 1 bright white bag, 2 muted yellow bags.\ndark orange bags contain 3 bright white bags, 4 muted yellow bags.\nbright white bags contain 1 shiny gold bag.\nmuted yellow bags contain 2 shiny gold bags, 9 faded blue bags.\nshiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.\ndark olive bags contain 3 faded blue bags, 4 dotted black bags.\nvibrant plum bags contain 5 faded blue bags, 6 dotted black bags.\nfaded blue bags contain no other bags.\ndotted black bags contain no other bags.")
      32

      iex> AdventOfCode.Day07.part2("shiny gold bags contain 2 dark red bags.\ndark red bags contain 2 dark orange bags.\ndark orange bags contain 2 dark yellow bags.\ndark yellow bags contain 2 dark green bags.\ndark green bags contain 2 dark blue bags.\ndark blue bags contain 2 dark violet bags.\ndark violet bags contain no other bags.")
      126

  """
  def part1(input) do
    parse_input(input)
    |> invert_map()
    |> (&possible_containers("shiny gold", &1)).()
    |> MapSet.new()
    |> Enum.count()
  end

  def part2(input) do
    parse_input(input)
    |> Map.new()
    |> (&num_bags("shiny gold", &1)).()
    |> (fn a -> a - 1 end).()
  end

  defp parse_input(input) do
    String.trim(input)
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [name, rest] = String.split(line, " bags contain ")

    rest = String.replace(rest, ~r/ bags?\.$/, "")

    contains =
      case rest do
        "no other" ->
          []

        rest ->
          rest
          |> String.split(~r/ bags?, /)
          |> Enum.map(fn part ->
            %{"amount" => amount, "name" => name} =
              Regex.named_captures(~r/^(?<amount>\d+) (?<name>.+)$/, part)

            {name, String.to_integer(amount)}
          end)
      end

    {name, contains}
  end

  defp invert_map(map) do
    Enum.reduce(map, %{}, fn {name, contains}, acc ->
      Enum.reduce(contains, acc, fn {contains_name, amount}, acc ->
        value =
          Map.get(acc, contains_name, [])
          |> Enum.concat([{name, amount}])

        Map.put(acc, contains_name, value)
      end)
    end)
  end

  defp possible_containers(node, map) do
    Map.get(map, node, [])
    |> Enum.flat_map(fn {parent, _} -> [parent] ++ possible_containers(parent, map) end)
  end

  defp num_bags(node, map) do
    Map.get(map, node, [])
    |> Enum.map(fn {child, amount} -> amount * num_bags(child, map) end)
    |> Enum.sum()
    |> (fn a -> a + 1 end).()
  end
end
