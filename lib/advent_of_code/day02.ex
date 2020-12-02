defmodule AdventOfCode.Day02 do
  @doc ~S"""
  ## Examples

      iex> AdventOfCode.Day02.part1("1-3 a: abcde\n1-3 b: cdefg\n2-9 c: ccccccccc")
      2

      iex> AdventOfCode.Day02.part2("1-3 a: abcde\n1-3 b: cdefg\n2-9 c: ccccccccc")
      1

  """
  def part1(input) do
    parse_input(input)
    |> Enum.filter(&is_not_corrupt_1/1)
    |> Enum.count()
  end

  def part2(input) do
    parse_input(input)
    |> Enum.filter(&is_not_corrupt_2/1)
    |> Enum.count()
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
  end

  @line_regex ~r/^(?<min>\d+)-(?<max>\d+) (?<char>\w): (?<pass>\w+)$/
  defp parse_line(line) do
    %{"char" => char, "max" => max, "min" => min, "pass" => pass} =
      Regex.named_captures(@line_regex, line)

    %{char: char, max: String.to_integer(max), min: String.to_integer(min), pass: pass}
  end

  defp is_not_corrupt_1(%{char: char, max: max, min: min, pass: pass}) do
    String.graphemes(pass)
    |> Enum.count(fn c -> c === char end)
    |> (fn val -> val >= min && val <= max end).()
  end

  defp is_not_corrupt_2(%{char: char, max: second_index, min: first_index, pass: pass}) do
    chars = String.graphemes(pass)

    [first_index - 1, second_index - 1]
    |> Enum.filter(fn index -> Enum.at(chars, index) === char end)
    |> Enum.count()
    |> (fn val -> val === 1 end).()
  end
end
