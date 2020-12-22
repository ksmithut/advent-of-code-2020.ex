defmodule AdventOfCode.Day22 do
  @doc ~S"""
  ## Examples

      iex> part1("Player 1:\n9\n2\n6\n3\n1\n\nPlayer 2:\n5\n8\n4\n7\n10")
      306

  """
  def part1(input) do
    parse_input(input)
    |> play_game()
    |> score_game()
  end

  @doc ~S"""
  ## Examples

      iex> part2("Player 1:\n9\n2\n6\n3\n1\n\nPlayer 2:\n5\n8\n4\n7\n10")
      291

  """
  def part2(input) do
    parse_input(input)
    |> play_recursive()
    |> score_game()
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(fn player_deck ->
      player_deck
      |> String.split("\n")
      |> List.delete_at(0)
      |> Enum.map(&String.to_integer/1)
    end)
    |> (fn [player_1, player_2] -> {player_1, player_2} end).()
  end

  defp play_game({deck_1, []}), do: {:player_1, deck_1}
  defp play_game({[], deck_2}), do: {:player_2, deck_2}

  defp play_game({[top_1 | deck_1], [top_2 | deck_2]}) when top_1 > top_2,
    do: play_game({deck_1 ++ [top_1, top_2], deck_2})

  defp play_game({[top_1 | deck_1], [top_2 | deck_2]}),
    do: play_game({deck_1, deck_2 ++ [top_2, top_1]})

  defp score_game({_, deck}) do
    deck
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {card, index}, total -> total + card * index end)
  end

  defp play_recursive(players, played_rounds \\ MapSet.new())
  defp play_recursive({deck_1, []}, _), do: {:player_1, deck_1}
  defp play_recursive({[], deck_2}, _), do: {:player_2, deck_2}

  defp play_recursive({deck_1, deck_2} = round, played_rounds) do
    if MapSet.member?(played_rounds, round) do
      {:player_1, deck_1}
    else
      [top_1 | deck_1] = deck_1
      [top_2 | deck_2] = deck_2

      if top_1 <= length(deck_1) and top_2 <= length(deck_2) do
        case play_recursive({Enum.slice(deck_1, 0, top_1), Enum.slice(deck_2, 0, top_2)}) do
          {:player_1, _} -> {deck_1 ++ [top_1, top_2], deck_2}
          {:player_2, _} -> {deck_1, deck_2 ++ [top_2, top_1]}
        end
      else
        if top_1 > top_2,
          do: {deck_1 ++ [top_1, top_2], deck_2},
          else: {deck_1, deck_2 ++ [top_2, top_1]}
      end
      |> play_recursive(MapSet.put(played_rounds, round))
    end
  end
end
