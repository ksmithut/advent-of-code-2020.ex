defmodule AdventOfCode.Day21 do
  @doc ~S"""
  ## Examples

      iex> part1("mxmxvkd kfcds sqjhc nhms (contains dairy, fish)\ntrh fvjkl sbzzf mxmxvkd (contains dairy)\nsqjhc fvjkl (contains soy)\nsqjhc mxmxvkd sbzzf (contains fish)")
      5

  """
  def part1(input) do
    lines = parse_input(input)

    alergen_mapping =
      figure_out_alergens(lines) |> Enum.map(fn {one, two} -> {two, one} end) |> Map.new()

    lines
    |> Enum.flat_map(fn {ingredients, _} -> ingredients end)
    |> Enum.count(fn ingredient ->
      !Map.has_key?(alergen_mapping, ingredient)
    end)
  end

  @doc ~S"""
  ## Examples

      iex> part2("mxmxvkd kfcds sqjhc nhms (contains dairy, fish)\ntrh fvjkl sbzzf mxmxvkd (contains dairy)\nsqjhc fvjkl (contains soy)\nsqjhc mxmxvkd sbzzf (contains fish)")
      "mxmxvkd,sqjhc,fvjkl"

  """
  def part2(input) do
    parse_input(input)
    |> figure_out_alergens()
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(&elem(&1, 1))
    |> Enum.join(",")
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    %{"ingredients" => ingredients, "alergens" => alergens} =
      Regex.named_captures(~r/^(?<ingredients>[^(]+) ?(\(contains (?<alergens>[^)]+)\))?$/, line)

    {String.split(ingredients, " ", trim: true), String.split(alergens, ", ", trim: true)}
  end

  defp figure_out_alergens(lines) do
    Enum.reduce(lines, %{}, fn {ingredients, alergens}, map ->
      ingredients = MapSet.new(ingredients)

      Enum.reduce(alergens, map, fn alergen, map ->
        Map.get(map, alergen, ingredients)
        |> MapSet.intersection(ingredients)
        |> (&Map.put(map, alergen, &1)).()
      end)
    end)
    |> resolve_alergens()
  end

  defp resolve_alergens(map) do
    {single, multiple} =
      Enum.split_with(map, fn {_, possibilities} -> MapSet.size(possibilities) === 1 end)

    single_possibilities =
      Enum.reduce(single, MapSet.new(), fn {_, possibilities}, all ->
        MapSet.union(all, possibilities)
      end)

    if length(multiple) === 0 do
      single
      |> Enum.map(fn {key, map_set} -> {key, MapSet.to_list(map_set) |> Enum.at(0)} end)
      |> Map.new()
    else
      multiple
      |> Enum.reduce(map, fn {key, possibilities}, map ->
        MapSet.difference(possibilities, single_possibilities)
        |> (&Map.put(map, key, &1)).()
      end)
      |> resolve_alergens()
    end
  end
end
