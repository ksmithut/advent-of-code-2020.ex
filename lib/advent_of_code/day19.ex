defmodule AdventOfCode.Day19 do
  @doc ~S"""
  ## Examples

      # iex> part1("0: 4 1 5\n1: 2 3 | 3 2\n2: 4 4 | 5 5\n3: 4 5 | 5 4\n4: \"a\"\n5: \"b\"\n\nababbb\nbababa\nabbbab\naaabbb\naaaabbb")
      # 2

  """
  def part1(input) do
    {rules, messages} = parse_input(input)
    rule0 = Map.get(rules, "0")
    Enum.count(messages, fn message -> rule0.(message, rules) === "" end)
  end

  @doc ~S"""
  ## Examples

      # iex> part2("42: 9 14 | 10 1\n9: 14 27 | 1 26\n10: 23 14 | 28 1\n1: \"a\"\n11: 42 31\n5: 1 14 | 15 1\n19: 14 1 | 14 14\n12: 24 14 | 19 1\n16: 15 1 | 14 14\n31: 14 17 | 1 13\n6: 14 14 | 1 14\n2: 1 24 | 14 4\n0: 8 11\n13: 14 3 | 1 12\n15: 1 | 14\n17: 14 2 | 1 7\n23: 25 1 | 22 14\n28: 16 1\n4: 1 1\n20: 14 14 | 1 15\n3: 5 14 | 16 1\n27: 1 6 | 14 18\n14: \"b\"\n21: 14 1 | 1 14\n25: 1 1 | 1 14\n22: 14 14\n8: 42\n26: 14 22 | 1 20\n18: 15 15\n7: 14 5 | 1 21\n24: 14 1\n\nabbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa\nbbabbbbaabaabba\nbabbbbaabbbbbabbbbbbaabaaabaaa\naaabbbbbbaaaabaababaabababbabaaabbababababaaa\nbbbbbbbaaaabbbbaaabbabaaa\nbbbababbbbaaaaaaaabbababaaababaabab\nababaaaaaabaaab\nababaaaaabbbaba\nbaabbaaaabbaaaababbaababb\nabbbbabbbbaaaababbbbbbaaaababb\naaaaabbaabaaaaababaa\naaaabbaaaabbaaa\naaaabbaabbaaaaaaabbbabbbaaabbaabaaa\nbabaaabbbaaabaababbaabababaaab\naabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba")
      # 12

      iex> part2("42: 9 14 | 10 1\n9: 14 27 | 1 26\n10: 23 14 | 28 1\n1: \"a\"\n11: 42 31\n5: 1 14 | 15 1\n19: 14 1 | 14 14\n12: 24 14 | 19 1\n16: 15 1 | 14 14\n31: 14 17 | 1 13\n6: 14 14 | 1 14\n2: 1 24 | 14 4\n0: 8 11\n13: 14 3 | 1 12\n15: 1 | 14\n17: 14 2 | 1 7\n23: 25 1 | 22 14\n28: 16 1\n4: 1 1\n20: 14 14 | 1 15\n3: 5 14 | 16 1\n27: 1 6 | 14 18\n14: \"b\"\n21: 14 1 | 1 14\n25: 1 1 | 1 14\n22: 14 14\n8: 42\n26: 14 22 | 1 20\n18: 15 15\n7: 14 5 | 1 21\n24: 14 1\n\nbabbbbaabbbbbabbbbbbaabaaabaaa")
      1

  """
  def part2(input) do
    input
    |> String.replace("\n8: 42\n", "\n8: 42 | 42 8\n")
    |> String.replace("\n11: 42 31\n", "\n11: 42 31 | 42 11 31\n")
    |> part1()
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
      String.contains?(rule, "\"") ->
        char = String.replace(rule, "\"", "")

        fn string, _ ->
          if String.first(string) === char,
            do: String.slice(string, 1..String.length(string)),
            else: nil
        end

      String.contains?(rule, " | ") ->
        part_rules =
          rule
          |> String.split(" | ")
          |> Enum.map(&parse_rule/1)

        fn string, rules ->
          Enum.find_value(part_rules, fn rule -> rule.(string, rules) end)
        end

      true ->
        part_rules = rule |> String.split(" ")

        fn string, rules ->
          part_rules
          |> Enum.map(fn rule -> Map.get(rules, rule) end)
          |> Enum.reduce_while(string, fn rule, acc ->
            case rule.(acc, rules) do
              nil -> {:halt, nil}
              val -> {:cont, val}
            end
          end)
        end
    end
  end
end
