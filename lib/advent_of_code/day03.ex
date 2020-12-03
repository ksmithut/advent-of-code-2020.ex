defmodule AdventOfCode.Day03 do
  alias __MODULE__.TreeMap

  @doc ~S"""
  ## Examples

      iex> AdventOfCode.Day03.part1("..##.......\n#...#...#..\n.#....#..#.\n..#.#...#.#\n.#...##..#.\n..#.##.....\n.#.#.#....#\n.#........#\n#.##...#...\n#...##....#\n.#..#...#.#")
      7

      iex> AdventOfCode.Day03.part2("..##.......\n#...#...#..\n.#....#..#.\n..#.#...#.#\n.#...##..#.\n..#.##.....\n.#.#.#....#\n.#........#\n#.##...#...\n#...##....#\n.#..#...#.#")
      336

  """
  def part1(input) do
    tree_map = TreeMap.parse(input)

    run_slope(tree_map, %{x: 0, y: 0}, %{right: 3, down: 1})
  end

  def part2(input) do
    tree_map = TreeMap.parse(input)

    [
      %{right: 1, down: 1},
      %{right: 3, down: 1},
      %{right: 5, down: 1},
      %{right: 7, down: 1},
      %{right: 1, down: 2}
    ]
    |> Enum.map(fn velocity -> run_slope(tree_map, %{x: 0, y: 0}, velocity) end)
    |> Enum.reduce(fn a, b -> a * b end)
  end

  def run_slope(
        tree_map,
        %{x: x, y: y},
        %{right: right, down: down} = velocity,
        encounters \\ []
      ) do
    case TreeMap.fetch(tree_map, x, y) do
      nil -> Enum.count(encounters, fn item -> item === :tree end)
      item -> run_slope(tree_map, %{x: x + right, y: y + down}, velocity, encounters ++ [item])
    end
  end
end

defmodule AdventOfCode.Day03.TreeMap do
  defstruct map: nil

  alias __MODULE__

  def parse(string_map) do
    map =
      string_map
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn line ->
        String.graphemes(line)
        |> Enum.map(fn
          "." -> :space
          "#" -> :tree
        end)
      end)

    %TreeMap{map: map}
  end

  def fetch(%TreeMap{map: map}, x, y) do
    case Enum.at(map, y) do
      nil -> nil
      row -> Enum.at(row, rem(x, length(row)))
    end
  end
end
