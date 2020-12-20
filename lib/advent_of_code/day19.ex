defmodule AdventOfCode.Day19 do
  @doc ~S"""
  ## Examples

      iex> part1("0: 4 1 5\n1: 2 3 | 3 2\n2: 4 4 | 5 5\n3: 4 5 | 5 4\n4: \"a\"\n5: \"b\"\n\nababbb\nbababa\nabbbab\naaabbb\naaaabbb")
      2

  """
  def part1(input) do
    {rules, messages} = parse_input(input)

    possibilities =
      Map.get(rules, "0").(rules)
      |> combos()
      |> MapSet.new()

    Enum.count(messages, fn message -> MapSet.member?(possibilities, message) end)
  end

  @doc ~S"""
  ## Examples

      iex> part2("hello")
      "hello"

  """
  def part2(input) do
    input
  end

  defp parse_input(input) do
    [rules, messages] = String.split(input, "\n\n", trim: true)
    {parse_rules(rules), String.split(messages, "\n", trim: true)}
  end

  defp parse_rules(rules_input) do
    rules_input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [index, rule] = String.split(line, ": ")

      {index, parse_rule(rule)}
    end)
    |> Map.new()
  end

  defp parse_rule(rule) do
    cond do
      Regex.match?(~r/^"(?<char>[^"]+)"$/, rule) ->
        %{"char" => char} = Regex.named_captures(~r/^"(?<char>[^"]+)"$/, rule)
        fn _ -> {:leaf, char} end

      String.contains?(rule, " | ") ->
        part_rules =
          rule
          |> String.split(" | ")
          |> Enum.map(&parse_rule/1)

        fn rules ->
          {:or, Enum.map(part_rules, fn rule -> rule.(rules) end)}
        end

      true ->
        part_rules = rule |> String.split(" ")

        fn rules ->
          {:sequence, Enum.map(part_rules, fn rule -> Map.get(rules, rule).(rules) end)}
        end
    end
  end

  defp combos({:leaf, char}), do: [char]

  defp combos({:sequence, sequence}) do
    sequence
    |> Enum.map(&combos/1)
    |> Enum.reduce(fn possibilities, all ->
      Enum.flat_map(all, fn prefix ->
        Enum.map(possibilities, fn combo ->
          "#{prefix}#{combo}"
        end)
      end)
    end)
  end

  defp combos({:or, paths}) do
    paths
    |> Enum.flat_map(&combos/1)
  end
end
