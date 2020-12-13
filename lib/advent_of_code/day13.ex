defmodule AdventOfCode.Day13 do
  @doc ~S"""
  ## Examples

      iex> part1("939\n7,13,x,x,59,x,31,19")
      295

      iex> part2("939\n7,13,x,x,59,x,31,19")
      1068781

      iex> part2("939\n17,x,13,19")
      3417

      iex> part2("939\n67,7,59,61")
      754018

      iex> part2("939\n67,x,7,59,61")
      779210

      iex> part2("939\n67,7,x,59,61")
      1261476

      iex> part2("939\n1789,37,47,1889")
      1202161486


  """
  def part1(input) do
    [earliest, parts] = String.split(input, "\n", trim: true)
    earliest_timestamp = String.to_integer(earliest)

    buses =
      String.split(parts, ",")
      |> Enum.filter(fn x -> x !== "x" end)
      |> Enum.map(&String.to_integer/1)

    latest_timestamp = earliest_timestamp + Enum.max(buses)

    earliest_timestamp..latest_timestamp
    |> Enum.find_value(fn timestamp ->
      Enum.find_value(buses, fn bus ->
        rem(timestamp, bus) === 0 && bus * (timestamp - earliest_timestamp)
      end)
    end)
  end

  def part2(input) do
    [_, parts] = String.split(input, "\n", trim: true)

    buses =
      String.split(parts, ",")
      |> Enum.with_index()
      |> Enum.filter(fn {x, _} -> x !== "x" end)
      |> Enum.map(fn {x, index} -> {String.to_integer(x), index} end)

    # https://brilliant.org/wiki/chinese-remainder-theorem/
    # N = n1 ​× n2​ × ⋯ × nk
    big_n = buses |> Enum.map(&elem(&1, 0)) |> Enum.reduce(&*/2)

    x =
      buses
      # for each i = 1,2,…,k compute:
      |> Enum.map(fn {ni, i} ->
        # yi​ = N / ni​
        yi = Integer.floor_div(big_n, ni)
        zi = calculate_zi(yi, ni)
        yi * zi * i
      end)
      |> Enum.sum()
      |> rem(big_n)

    big_n - x
  end

  def calculate_zi(yi, ni, num \\ 1) do
    case rem(num * yi, ni) do
      1 -> num
      _ -> calculate_zi(yi, ni, num + 1)
    end
  end
end
