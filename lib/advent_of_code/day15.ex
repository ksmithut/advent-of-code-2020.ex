defmodule AdventOfCode.Day15 do
  @doc ~S"""
  ## Examples

      iex> part1("0,3,6")
      436

      iex> part1("1,3,2")
      1

      iex> part1("2,1,3")
      10

      iex> part1("1,2,3")
      27

      iex> part1("2,3,1")
      78

      iex> part1("3,2,1")
      438

      iex> part1("3,1,2")
      1836

      iex> part2("0,3,6")
      175594

  """
  def part1(input) do
    parse_input(input)
    |> element_at(2020)
  end

  def part2(input) do
    parse_input(input)
    |> element_at(30_000_000)
  end

  defp parse_input(input) do
    String.trim(input)
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp element_at(list, pos) do
    list
    |> Enum.with_index()
    |> Map.new()
    |> run_element_at(List.last(list), length(list), pos)
  end

  defp run_element_at(_, prev_value, index, end_index) when index >= end_index, do: prev_value

  defp run_element_at(last_indexes, prev_value, index, end_index) do
    prev_index = index - 1
    next_value = prev_index - Map.get(last_indexes, prev_value, prev_index)

    Map.put(last_indexes, prev_value, prev_index)
    |> run_element_at(next_value, index + 1, end_index)
  end
end
