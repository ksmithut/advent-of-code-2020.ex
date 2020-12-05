defmodule AdventOfCode.Day05 do
  @doc ~S"""
  ## Examples

      iex> AdventOfCode.Day05.part1("FBFBBFFRLR")
      357

      iex> AdventOfCode.Day05.part1("BFFFBBFRRR\nFFFBBBFRRR\nBBFFBBFRLL")
      820

  """
  def part1(input) do
    parse_input(input)
    |> Enum.max_by(&Map.get(&1, :id))
    |> Map.get(:id)
  end

  def part2(input) do
    seats = parse_input(input)

    Enum.group_by(seats, &Map.get(&1, :row))
    |> Enum.sort_by(fn {row, _} -> row end)
    # it will never be the first row, or the last, but we should find the row we
    # need by then
    |> List.delete_at(0)
    |> Enum.find_value(fn {_, row} -> length(row) !== 8 && row end)
    |> find_missing_seat()
    |> Map.get(:id)
  end

  defp parse_input(input) do
    String.trim(input)
    |> String.split("\n")
    |> Enum.map(&parse_seat/1)
  end

  defp parse_seat(input) do
    {row, col} = String.split_at(input, 7)
    {row, _} = row |> String.replace("F", "0") |> String.replace("B", "1") |> Integer.parse(2)

    {col, _} =
      col
      |> String.replace("L", "0")
      |> String.replace("R", "1")
      |> Integer.parse(2)

    %{row: row, col: col, id: row * 8 + col}
  end

  defp find_missing_seat(row_seats) do
    row = Enum.at(row_seats, 0) |> Map.get(:row)
    total = Enum.map(row_seats, &Map.get(&1, :col)) |> Enum.sum()
    col = 28 - total
    %{row: row, col: col, id: row * 8 + col}
  end
end
