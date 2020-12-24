defmodule AdventOfCode.Day24 do
  @doc ~S"""
  ## Examples

      iex> part1("sesenwnenenewseeswwswswwnenewsewsw\nneeenesenwnwwswnenewnwwsewnenwseswesw\nseswneswswsenwwnwse\nnwnwneseeswswnenewneswwnewseswneseene\nswweswneswnenwsewnwneneseenw\neesenwseswswnenwswnwnwsewwnwsene\nsewnenenenesenwsewnenwwwse\nwenwwweseeeweswwwnwwe\nwsweesenenewnwwnwsenewsenwwsesesenwne\nneeswseenwwswnwswswnw\nnenwswwsewswnenenewsenwsenwnesesenew\nenewnwewneswsewnwswenweswnenwsenwsw\nsweneswneswneneenwnewenewwneswswnese\nswwesenesewenwneswnwwneseswwne\nenesenwswwswneneswsenwnewswseenwsese\nwnwnesenesenenwwnenwsewesewsesesew\nnenewswnwewswnenesenwnesewesw\neneswnwswnwsenenwnwnwwseeswneewsenese\nneswnwewnwnwseenwseesewsenwsweewe\nwseweeenwnesenwwwswnew")
      10

  """
  def part1(input) do
    follow_instructions(input)
    |> Enum.count(&elem(&1, 1))
  end

  @doc ~S"""
  ## Examples

      iex> part2("sesenwnenenewseeswwswswwnenewsewsw\nneeenesenwnwwswnenewnwwsewnenwseswesw\nseswneswswsenwwnwse\nnwnwneseeswswnenewneswwnewseswneseene\nswweswneswnenwsewnwneneseenw\neesenwseswswnenwswnwnwsewwnwsene\nsewnenenenesenwsewnenwwwse\nwenwwweseeeweswwwnwwe\nwsweesenenewnwwnwsenewsenwwsesesenwne\nneeswseenwwswnwswswnw\nnenwswwsewswnenenewsenwsenwnesesenew\nenewnwewneswsewnwswenweswnenwsenwsw\nsweneswneswneneenwnewenewwneswswnese\nswwesenesewenwneswnwwneseswwne\nenesenwswwswneneswsenwnewswseenwsese\nwnwnesenesenenwwnenwsewesewsesesew\nnenewswnwewswnenesenwnesewesw\neneswnwswnwsenenwnwnwwseeswneewsenese\nneswnwewnwnwseenwseesewsenwsweewe\nwseweeenwnesenwwwswnew")
      2208

  """
  def part2(input) do
    follow_instructions(input)
    |> run_day(100)
    |> Enum.count(&elem(&1, 1))
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(""), do: []
  defp parse_line("e" <> rest), do: ["e" | parse_line(rest)]
  defp parse_line("se" <> rest), do: ["se" | parse_line(rest)]
  defp parse_line("sw" <> rest), do: ["sw" | parse_line(rest)]
  defp parse_line("w" <> rest), do: ["w" | parse_line(rest)]
  defp parse_line("nw" <> rest), do: ["nw" | parse_line(rest)]
  defp parse_line("ne" <> rest), do: ["ne" | parse_line(rest)]

  defp follow_instructions(input) do
    parse_input(input)
    |> Enum.map(&run_line({0, 0}, &1))
    |> Enum.reduce(%{}, fn pos, map ->
      is_black = Map.get(map, pos, false)
      Map.put(map, pos, !is_black)
    end)
  end

  defp run_line(pos, []), do: pos
  defp run_line(pos, [dir | rest]), do: move(pos, dir) |> run_line(rest)

  # Thank you https://www.redblobgames.com/grids/hexagons/#coordinates-offset
  defp move({x, y}, "e"), do: {x + 1, y}
  defp move({x, y}, "w"), do: {x - 1, y}

  defp move({x, y}, "nw") do
    if is_even(y), do: {x - 1, y - 1}, else: {x, y - 1}
  end

  defp move({x, y}, "ne") do
    if is_even(y), do: {x, y - 1}, else: {x + 1, y - 1}
  end

  defp move({x, y}, "se") do
    if is_even(y), do: {x, y + 1}, else: {x + 1, y + 1}
  end

  defp move({x, y}, "sw") do
    if is_even(y), do: {x - 1, y + 1}, else: {x, y + 1}
  end

  defp is_even(num), do: rem(num, 2) === 0

  defp run_day(map, 0), do: map

  defp run_day(map, times) do
    map
    |> Stream.filter(&elem(&1, 1))
    |> Stream.map(&elem(&1, 0))
    |> Stream.flat_map(&neighbors/1)
    |> Stream.uniq()
    |> Stream.map(&{&1, run_tile(&1, map)})
    |> Map.new()
    |> run_day(times - 1)
  end

  defp run_tile(pos, map) do
    is_black = Map.get(map, pos, false)

    black_neighbors =
      neighbors(pos)
      |> Enum.count(&Map.get(map, &1, false))

    cond do
      is_black && (black_neighbors === 0 || black_neighbors > 2) -> false
      !is_black && black_neighbors === 2 -> true
      true -> is_black
    end
  end

  defp neighbors(pos) do
    [
      move(pos, "e"),
      move(pos, "w"),
      move(pos, "nw"),
      move(pos, "ne"),
      move(pos, "se"),
      move(pos, "sw")
    ]
  end
end
