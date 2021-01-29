defmodule AdventOfCode.Day25 do
  @doc ~S"""
  ## Examples

      iex> part1("5764801\n17807724")
      14897079

  """
  def part1(input) do
    {card, door} = parse_input(input)

    card_loop_size = determine_loop_size(7, card)

    run_loop(door, door, card_loop_size)
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp determine_loop_size(subject, public_key, loop_size \\ 0, value \\ nil) do
    (value || subject)
    |> run_loop(subject)
    |> case do
      ^public_key -> loop_size + 1
      value -> determine_loop_size(subject, public_key, loop_size + 1, value)
    end
  end

  defp run_loop(value, subject) do
    (value * subject)
    |> rem(20_201_227)
  end

  defp run_loop(value, _, 0), do: value

  defp run_loop(value, subject, times),
    do: run_loop(value, subject) |> run_loop(subject, times - 1)
end
