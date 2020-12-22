defmodule AdventOfCode.Day20 do
  alias __MODULE__.Tile

  @doc ~S"""
  ## Examples

      iex> part1("Tile 2311:\n..##.#..#.\n##..#.....\n#...##..#.\n####.#...#\n##.##.###.\n##...#.###\n.#.#.#..##\n..#....#..\n###...#.#.\n..###..###\n\nTile 1951:\n#.##...##.\n#.####...#\n.....#..##\n#...######\n.##.#....#\n.###.#####\n###.##.##.\n.###....#.\n..#.#..#.#\n#...##.#..\n\nTile 1171:\n####...##.\n#..##.#..#\n##.#..#.#.\n.###.####.\n..###.####\n.##....##.\n.#...####.\n#.##.####.\n####..#...\n.....##...\n\nTile 1427:\n###.##.#..\n.#..#.##..\n.#.##.#..#\n#.#.#.##.#\n....#...##\n...##..##.\n...#.#####\n.#.####.#.\n..#..###.#\n..##.#..#.\n\nTile 1489:\n##.#.#....\n..##...#..\n.##..##...\n..#...#...\n#####...#.\n#..#.#.#.#\n...#.#.#..\n##.#...##.\n..##.##.##\n###.##.#..\n\nTile 2473:\n#....####.\n#..#.##...\n#.##..#...\n######.#.#\n.#...#.#.#\n.#########\n.###.#..#.\n########.#\n##...##.#.\n..###.#.#.\n\nTile 2971:\n..#.#....#\n#...###...\n#.#.###...\n##.##..#..\n.#####..##\n.#..####.#\n#..#.#..#.\n..####.###\n..#.#.###.\n...#.#.#.#\n\nTile 2729:\n...#.#.#.#\n####.#....\n..#.#.....\n....#..#.#\n.##..##.#.\n.#.####...\n####.#.#..\n##.####...\n##..#.##..\n#.##...##.\n\nTile 3079:\n#.#.#####.\n.#..######\n..#.......\n######....\n####.#..#.\n.#...#.##.\n#.#####.##\n..#.###...\n..#.......\n..#.###...")
      20899048083289

  """
  def part1(input) do
    parse_input(input)
    |> combos()
    |> Enum.reduce(%{}, fn {tile_a, tile_b}, map ->
      matching_edges = Tile.matching_edges(tile_a, tile_b)
      flipped_edges = Enum.map(matching_edges, fn {a, b} -> {b, a} end)

      map
      |> Map.get(tile_a, %{})
      |> Map.put(tile_b, matching_edges)
      |> (&Map.put(map, tile_a, &1)).()
      |> Map.get(tile_b, %{})
      |> Map.put(tile_a, flipped_edges)
      |> (&Map.put(map, tile_b, &1)).()
    end)
    |> Enum.filter(fn {_, matching_edges} -> map_size(matching_edges) === 2 end)
    |> length()
  end

  @doc ~S"""
  ## Examples

      iex> part2("hello")
      "hello"

  """
  def part2(input) do
    input
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(&Tile.parse/1)
  end

  defp combos([]), do: []
  defp combos([val | rest]), do: Enum.map(rest, &{val, &1}) |> Enum.concat(combos(rest))
end

defmodule AdventOfCode.Day20.Tile do
  defstruct map: nil, id: nil, width: 0, height: 0
  alias __MODULE__

  def parse(input) do
    [id_line | rows] = String.split(input, "\n", trim: true)
    %{"id" => id} = Regex.named_captures(~r/^Tile (?<id>\d+):$/, id_line)
    height = length(rows)
    width = Enum.at(rows, 0) |> String.length()

    map =
      rows
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.map(fn {cell, x} -> {{x, y}, cell} end)
      end)
      |> Map.new()

    %Tile{map: map, id: String.to_integer(id), width: width, height: height}
  end

  def edges(%Tile{map: map, width: width, height: height}) do
    max_x = width - 1
    max_y = height - 1
    top = for x <- 0..max_x, do: Map.get(map, {x, 0})
    right = for y <- 0..max_y, do: Map.get(map, {max_x, y})
    bottom = for x <- max_x..0, do: Map.get(map, {x, max_y})
    left = for y <- max_y..0, do: Map.get(map, {0, y})
    [{:top, top}, {:right, right}, {:bottom, bottom}, {:left, left}]
  end

  def flip_horizontal(%Tile{map: map, width: width} = tile) do
    max_x = width - 1

    map =
      map
      |> Enum.map(fn {{x, y}, _} -> {{x, y}, Map.get(map, {max_x - x, y})} end)
      |> Map.new()

    %Tile{tile | map: map}
  end

  def flip_vertical(%Tile{map: map, height: height} = tile) do
    max_y = height - 1

    map =
      map
      |> Enum.map(fn {{x, y}, _} -> {{x, y}, Map.get(map, {x, max_y - y})} end)
      |> Map.new()

    %Tile{tile | map: map}
  end

  def matching_edges(%Tile{} = tile_a, %Tile{} = tile_b) do
    edges_a = edges(tile_a)
    edges_b = edges(tile_b) |> Enum.map(fn {dir, edge} -> {dir, Enum.reverse(edge)} end)

    Enum.flat_map(edges_a, fn {dir_a, edge_a} ->
      edges_b
      |> Enum.filter(fn {_, edge_b} -> edge_a === edge_b end)
      |> Enum.map(fn {dir_b, _} -> {dir_a, dir_b} end)
    end)
  end
end
