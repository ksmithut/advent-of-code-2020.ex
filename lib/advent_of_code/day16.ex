defmodule AdventOfCode.Day16 do
  @doc ~S"""
  ## Examples

      iex> part1("class: 1-3 or 5-7\nrow: 6-11 or 33-44\nseat: 13-40 or 45-50\n\nyour ticket:\n7,1,14\n\nnearby tickets:\n7,3,47\n40,4,50\n55,2,20\n38,6,12")
      71

  """
  def part1(input) do
    %{ranges: ranges, nearby_tickets: nearby_tickets} = parse_input(input)

    ranges = Enum.flat_map(ranges, fn {_, ranges} -> ranges end)

    nearby_tickets
    |> Enum.flat_map(&invalid_numbers(&1, ranges))
    |> Enum.sum()
  end

  @doc ~S"""
  ## Examples

      iex> part2("class: 0-1 or 4-19\nrow: 0-5 or 8-19\nseat: 0-13 or 16-19\n\nyour ticket:\n11,12,13\n\nnearby tickets:\n3,9,18\n15,1,5\n5,14,9", fn field -> true end)
      1716

  """
  def part2(input, row_filter \\ &starts_with_departure/1) do
    %{ranges: ranges, your_ticket: your_ticket, nearby_tickets: nearby_tickets} =
      parse_input(input)

    columns = possible_fields(your_ticket, ranges)

    Enum.reduce_while(nearby_tickets, columns, fn ticket, columns ->
      possibilities = possible_fields(ticket, ranges)

      new_columns =
        possibilities
        |> Enum.with_index()
        |> Enum.map(fn {possible_columns, index} ->
          MapSet.intersection(possible_columns, Enum.at(columns, index))
        end)

      Enum.frequencies_by(new_columns, &MapSet.size/1)
      |> Map.keys()
      |> Enum.sort()
      |> case do
        [0 | _] ->
          {:cont, columns}

        [1] ->
          {:halt, new_columns}

        _ ->
          {:cont, new_columns}
      end
    end)
    |> resolve_columns()
    |> Enum.zip(your_ticket)
    |> Enum.filter(fn {col, _} -> row_filter.(col) end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.reduce(&*/2)
  end

  defp starts_with_departure("departure" <> _), do: true
  defp starts_with_departure(_), do: false

  defp parse_input(input) do
    [ranges, your_ticket, nearby_tickets] = String.split(input, "\n\n", trim: true)

    ranges =
      ranges
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [_, name | ranges] = Regex.run(~r/([^:]+): (\d+)-(\d+) or (\d+)-(\d+)/, line)
        [r1s, r1e, r2s, r2e] = Enum.map(ranges, &String.to_integer/1)
        {name, [r1s..r1e, r2s..r2e]}
      end)

    your_ticket =
      your_ticket
      |> String.split("\n", trim: true)
      |> Enum.at(1)
      |> parse_ticket()

    nearby_tickets =
      nearby_tickets
      |> String.split("\n", trim: true)
      |> List.delete_at(0)
      |> Enum.map(&parse_ticket/1)

    %{ranges: ranges, your_ticket: your_ticket, nearby_tickets: nearby_tickets}
  end

  defp parse_ticket(line) do
    line
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp invalid_numbers(ticket, ranges) do
    Enum.reduce(ticket, [], fn num, invalid ->
      valid = Enum.any?(ranges, fn range -> num in range end)
      if valid, do: invalid, else: [num | invalid]
    end)
  end

  defp possible_fields(ticket, ranges) do
    Enum.map(ticket, fn num ->
      ranges
      |> Enum.filter(fn {_, ranges} ->
        Enum.any?(ranges, fn range -> num in range end)
      end)
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()
    end)
  end

  defp resolve_columns(columns) do
    {single, multiple} = Enum.split_with(columns, fn column -> MapSet.size(column) === 1 end)

    single = Enum.concat(single) |> MapSet.new()

    if length(multiple) === 0 do
      columns
      |> Enum.map(&MapSet.to_list/1)
      |> Enum.map(&Enum.at(&1, 0))
    else
      columns
      |> Enum.map(fn column ->
        case MapSet.size(column) do
          1 -> column
          _ -> MapSet.difference(column, single)
        end
      end)
      |> resolve_columns()
    end
  end
end
