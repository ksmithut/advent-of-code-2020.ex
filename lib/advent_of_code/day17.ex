defmodule AdventOfCode.Day17 do
  alias __MODULE__.PocketDimension

  @doc ~S"""
  ## Examples

      iex> part1(".#.\n..#\n###")
      112

  """
  def part1(input) do
    PocketDimension.parse(input)
    |> PocketDimension.run_times(6)
    |> PocketDimension.active_count()
  end

  @doc ~S"""
  ## Examples

      iex> part2(".#.\n..#\n###")
      848

  """
  def part2(input) do
    PocketDimension.parse(input, 4)
    |> PocketDimension.run_times(6)
    |> PocketDimension.active_count()
  end
end

defmodule AdventOfCode.Day17.PocketDimension do
  defstruct state: MapSet.new(), dimensions: 3

  alias __MODULE__

  def parse(input, dimensions \\ 3) do
    extra_dimensions = for _ <- 1..(dimensions - 2), do: 0

    state =
      String.split(input, "\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        String.split(row, "", trim: true)
        |> Enum.with_index()
        |> Enum.filter(fn {state, _} -> state === "#" end)
        |> Enum.map(fn {_, x} -> List.to_tuple([x, y] ++ extra_dimensions) end)
      end)
      |> MapSet.new()

    %PocketDimension{state: state, dimensions: dimensions}
  end

  def run_times(%PocketDimension{} = pd, 0), do: pd
  def run_times(_, x) when x < 0, do: nil
  def run_times(%PocketDimension{} = pd, x), do: run(pd) |> run_times(x - 1)

  def run(%PocketDimension{state: state, dimensions: dimensions} = pd) do
    state =
      0..(dimensions - 1)
      |> Enum.map(fn index ->
        {min, max} = Enum.map(state, &elem(&1, index)) |> Enum.min_max()
        (min - 1)..(max + 1)
      end)
      |> ranges_flat_map(fn pos ->
        active_count = get_neighbors(pd, pos) |> Enum.count(& &1)

        case get(pd, pos) do
          true ->
            if active_count === 2 or active_count === 3, do: [pos], else: []

          false ->
            if active_count === 3, do: [pos], else: []
        end
      end)
      |> MapSet.new()

    %PocketDimension{state: state, dimensions: dimensions}
  end

  def get(%PocketDimension{state: state}, pos) do
    MapSet.member?(state, pos)
  end

  defp get_neighbors(pd, pos) do
    Tuple.to_list(pos)
    |> Enum.map(fn x -> (x - 1)..(x + 1) end)
    |> ranges_flat_map(fn
      ^pos -> []
      pos -> [get(pd, pos)]
    end)
  end

  def active_count(%PocketDimension{state: state}) do
    MapSet.size(state)
  end

  defp ranges_flat_map(ranges, map, tuple \\ {})
  defp ranges_flat_map([], map, tuple), do: map.(tuple)

  defp ranges_flat_map([range | ranges], map, tuple) do
    Enum.flat_map(range, fn pos -> ranges_flat_map(ranges, map, Tuple.append(tuple, pos)) end)
  end
end
