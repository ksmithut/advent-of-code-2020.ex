defmodule AdventOfCode.Day09 do
  @doc ~S"""
  ## Examples

      iex> part1("35\n20\n15\n25\n47\n40\n62\n55\n65\n95\n102\n117\n150\n182\n127\n219\n299\n277\n309\n576", 5)
      127

      iex> part2("35\n20\n15\n25\n47\n40\n62\n55\n65\n95\n102\n117\n150\n182\n127\n219\n299\n277\n309\n576", 5)
      62

  """
  def part1(input, size \\ 25) do
    parse_input(input)
    |> Enum.chunk_every(size + 1, 1, :discard)
    |> Enum.find(fn list ->
      to_find = List.last(list)
      list = Enum.take(list, size)

      !Enum.any?(list, fn item ->
        sub_list = List.delete(list, item)
        diff = to_find - item
        Enum.member?(sub_list, diff)
      end)
    end)
    |> List.last()
  end

  def part2(input, size \\ 25) do
    to_find = part1(input, size)

    list = parse_input(input)
    last_index = length(list) - 1

    list
    |> Enum.with_index()
    |> Enum.find_value(fn {_, first_index} ->
      Enum.slice(list, first_index..last_index)
      |> Enum.with_index()
      |> Enum.reduce_while(0, fn {last, index}, count ->
        total = last + count

        cond do
          total === to_find -> {:halt, Enum.slice(list, first_index, index)}
          total > to_find -> {:halt, nil}
          true -> {:cont, total}
        end
      end)
    end)
    |> Enum.min_max()
    |> Tuple.to_list()
    |> Enum.sum()
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
