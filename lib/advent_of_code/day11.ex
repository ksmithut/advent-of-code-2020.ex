defmodule AdventOfCode.Day11 do
  alias __MODULE__.Layout

  @doc ~S"""
  ## Examples

      iex> part1("L.LL.LL.LL\nLLLLLLL.LL\nL.L.L..L..\nLLLL.LL.LL\nL.LL.LL.LL\nL.LLLLL.LL\n..L.L.....\nLLLLLLLLLL\nL.LLLLLL.L\nL.LLLLL.LL")
      37

      iex> part2("L.LL.LL.LL\nLLLLLLL.LL\nL.L.L..L..\nLLLL.LL.LL\nL.LL.LL.LL\nL.LLLLL.LL\n..L.L.....\nLLLLLLLLLL\nL.LLLLLL.L\nL.LLLLL.LL")
      26

  """
  def part1(input) do
    input
    |> Layout.new()
    |> Layout.run(&evaluate_part1/3)
    |> Layout.count_occupied()
  end

  defp evaluate_part1(layout, pos, value) do
    case value do
      :floor ->
        :floor

      :empty ->
        if count_adjascent_occupied(layout, pos) === 0, do: :occupied, else: :empty

      :occupied ->
        if count_adjascent_occupied(layout, pos) >= 4, do: :empty, else: :occupied
    end
  end

  defp count_adjascent_occupied(%{map: map}, {x, y}) do
    [
      Map.get(map, {x - 1, y - 1}),
      Map.get(map, {x, y - 1}),
      Map.get(map, {x + 1, y - 1}),
      Map.get(map, {x - 1, y}),
      Map.get(map, {x + 1, y}),
      Map.get(map, {x - 1, y + 1}),
      Map.get(map, {x, y + 1}),
      Map.get(map, {x + 1, y + 1})
    ]
    |> Enum.count(fn val -> val === :occupied end)
  end

  def part2(input) do
    input
    |> Layout.new()
    |> Layout.run(&evaluate_part2/3)
    |> Layout.count_occupied()
  end

  defp evaluate_part2(layout, pos, value) do
    case value do
      :floor ->
        :floor

      :empty ->
        if count_in_view_occupied(layout, pos) === 0, do: :occupied, else: :empty

      :occupied ->
        if count_in_view_occupied(layout, pos) >= 5, do: :empty, else: :occupied
    end
  end

  defp count_in_view_occupied(layout, pos) do
    [
      find(:up_left, layout, pos),
      find(:up, layout, pos),
      find(:up_right, layout, pos),
      find(:left, layout, pos),
      find(:right, layout, pos),
      find(:down_left, layout, pos),
      find(:down, layout, pos),
      find(:down_right, layout, pos)
    ]
    |> Enum.count(fn val -> val === :occupied end)
  end

  defp find_next(dir, %{map: map} = layout, pos) do
    case Map.get(map, pos) do
      :floor ->
        find(dir, layout, pos)

      other ->
        other
    end
  end

  defp find(:up_left = dir, layout, {x, y}), do: find_next(dir, layout, {x - 1, y - 1})
  defp find(:up = dir, layout, {x, y}), do: find_next(dir, layout, {x, y - 1})
  defp find(:up_right = dir, layout, {x, y}), do: find_next(dir, layout, {x + 1, y - 1})
  defp find(:left = dir, layout, {x, y}), do: find_next(dir, layout, {x - 1, y})
  defp find(:right = dir, layout, {x, y}), do: find_next(dir, layout, {x + 1, y})
  defp find(:down_left = dir, layout, {x, y}), do: find_next(dir, layout, {x - 1, y + 1})
  defp find(:down = dir, layout, {x, y}), do: find_next(dir, layout, {x, y + 1})
  defp find(:down_right = dir, layout, {x, y}), do: find_next(dir, layout, {x + 1, y + 1})
end

defmodule AdventOfCode.Day11.Layout do
  defstruct map: []

  alias __MODULE__

  def new(input) do
    map =
      String.split(input, "\n", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, y}, map ->
        String.graphemes(line)
        |> Enum.map(&parse_cell/1)
        |> Enum.with_index()
        |> Enum.reduce(map, fn {cell, x}, map ->
          Map.put(map, {x, y}, cell)
        end)
      end)

    %Layout{map: map}
  end

  def run(%Layout{} = layout, evaluate) do
    # IO.puts(render(layout))
    # IO.puts("===================\n")
    next_layout = tick(layout, evaluate)
    if equal(next_layout, layout), do: next_layout, else: run(next_layout, evaluate)
  end

  def count_occupied(%Layout{map: map}) do
    Enum.count(map, fn {_, value} -> value === :occupied end)
  end

  defp tick(%Layout{map: map} = layout, evaluate) do
    map =
      Enum.map(map, fn {key, value} ->
        {key, evaluate.(layout, key, value)}
      end)
      |> Map.new()

    %Layout{map: map}
  end

  defp parse_cell("L"), do: :empty
  defp parse_cell("."), do: :floor

  defp equal(%Layout{map: map1}, %Layout{map: map2}) do
    Map.equal?(map1, map2)
  end

  # defp render(%Layout{map: map}) do
  #   keys = Map.keys(map)
  #   {min_x, max_x} = Enum.map(keys, fn {x, _} -> x end) |> Enum.min_max()
  #   {min_y, max_y} = Enum.map(keys, fn {_, y} -> y end) |> Enum.min_max()

  #   Enum.map(min_y..max_y, fn y ->
  #     Enum.map(min_x..max_x, fn x ->
  #       case Map.get(map, {x, y}) do
  #         :floor -> "."
  #         :occupied -> "#"
  #         :empty -> "L"
  #       end
  #     end)
  #     |> Enum.join()
  #   end)
  #   |> Enum.join("\n")
  # end
end
