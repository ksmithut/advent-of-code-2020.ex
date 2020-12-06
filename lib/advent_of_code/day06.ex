defmodule AdventOfCode.Day06 do
  @doc ~S"""
  ## Examples

      iex> AdventOfCode.Day06.part1("abcx\nabcy\nabcz")
      6

      iex> AdventOfCode.Day06.part1("abc\n\na\nb\nc\n\nab\nac\n\na\na\na\na\n\nb")
      11

      iex> AdventOfCode.Day06.part2("abc\n\na\nb\nc\n\nab\nac\n\na\na\na\na\n\nb")
      6

  """
  def part1(input) do
    parse_input(input)
    |> Enum.map(&count_group_yes/1)
    |> Enum.sum()
  end

  def part2(input) do
    parse_input(input)
    |> Enum.map(&count_group_all_yes/1)
    |> Enum.sum()
  end

  defp parse_input(input) do
    String.trim(input)
    |> String.split("\n\n")
    |> Enum.map(&parse_group/1)
  end

  defp parse_group(group) do
    String.split(group, "\n")
    |> Enum.map(fn line ->
      String.graphemes(line) |> MapSet.new()
    end)
  end

  defp count_group_yes(group) do
    group
    |> Enum.reduce(&MapSet.union/2)
    |> MapSet.size()
  end

  defp count_group_all_yes(group) do
    group
    |> Enum.reduce(&MapSet.intersection/2)
    |> MapSet.size()
  end
end
